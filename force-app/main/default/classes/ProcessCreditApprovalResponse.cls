/**
 *  Author: Cloud Lending Solutions
 *  Summary: This class Process the received email from DLL through Email Service
 *
 **/
global class ProcessCreditApprovalResponse implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.Inboundenvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        String tempstr, ats_ref_number, legal_name, senders_ref, emailSubject;
        cllease__Batch_Process_Log__c log;
        String message;
        Savepoint sp = database.setsavepoint();
        try {
            System.debug(LoggingLevel.ERROR, 'Processing Email Started- Email Subject: '+email.subject);
            System.debug(LoggingLevel.ERROR, 'email.plainTextBody: '+email.plainTextBody);
            emailSubject = email.subject;
            //if the incoming email is response of the credit approval request, process it
            if (email.subject.contains('Credit') && email.subject.contains('application #')) {
                
                //take out the Approval or Declined line from the email body
                if (email.plainTextBody.contains('|Approval|')) {
                    tempstr = email.plainTextBody.substring(email.plainTextBody.indexof('|Approval|') + 10, email.plainTextBody.lastindexof('|'));
                }

                if (email.plainTextBody.contains('|Declined|')) {
                    tempstr = email.plainTextBody.substring(email.plainTextBody.indexof('|Declined|') + 10, email.plainTextBody.lastindexof('|'));
                }

                if (tempstr !=null && tempstr.length() > 0) {
                    // legal_name = tempstr.substring(0,tempstr.indexof('|'));
                    // senders_ref = tempstr.substring(tempstr.indexof('|')+1,tempstr.length());
                    //store the legal name and Credit approval request number
                    legal_name = tempstr.substring(0, tempstr.indexof('|'));
                    string temp_str2 = tempstr.substring(tempstr.indexof('|') + 1, tempstr.length());

                    if (temp_str2.contains(':')) {
                        senders_ref = temp_str2.substring(0, temp_str2.indexof('|')).substring(0, temp_str2.indexof(':'));
                    } else {
                        senders_ref = temp_str2.substring(0, temp_str2.indexof('|'));    
                    }
                    
                    ats_ref_number = temp_str2.substring(temp_str2.indexof('|') + 1, temp_str2.length() - 1);

                    System.debug(LoggingLevel.ERROR, 'legal_name: '+legal_name);
                    System.debug(LoggingLevel.ERROR, 'senders_ref: '+senders_ref);
                    System.debug(LoggingLevel.ERROR, 'ats_ref_number: '+ats_ref_number);

                    //query the credit approval record to be updated
                    genesis__Quick_Quotes__c  Credit_approval = [SELECT Id, Name,
                                                                    ATS_Reference_Number__c, 
                                                                    genesis__Status__c, 
                                                                    genesis__Business_Name__c, 
                                                                    Approved_Credit_Amount__c, 
                                                                    Estimated_Financed_Amount__c, 
                                                                    Credit_Approval_Date__c, 
                                                                    Credit_Approval_Expiration_Date__c 
                                                                FROM genesis__Quick_Quotes__c 
                                                                WHERE Name = :senders_ref];

                    //if approved
                    if (email.plainTextBody.contains('|Approval|')) {
                        Credit_approval.genesis__Status__c = 'CREDIT APPROVED';
                        Credit_approval.genesis__Business_Name__c = legal_name;
                        Credit_approval.Approved_Credit_Amount__c = Decimal.valueOf(Credit_approval.Estimated_Financed_Amount__c);
                        Credit_approval.Credit_Approval_Date__c = system.today();
                        Credit_approval.Credit_Approval_Expiration_Date__c = system.today() + 90;
                        Credit_approval.ATS_Reference_Number__c = ats_ref_number;
                    }

                    //if declined
                    if (email.plainTextBody.contains('|Declined|')) {
                        Credit_approval.genesis__Status__c = 'CREDIT DECLINED';
                        Credit_approval.Credit_Approval_Date__c = system.today();
                        Credit_approval.Credit_Approval_Expiration_Date__c = system.today() + 90;
                        Credit_approval.ATS_Reference_Number__c = ats_ref_number;
                    }

                    //update the credit approval record
                    Update Credit_approval;

                    //attach the approval letter to the credit approval record
                    if (email.binaryAttachments != null) {
                        for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                            Attachment attachment = new Attachment();
                            attachment.Name = bAttachment.fileName;
                            attachment.Body = bAttachment.body;
                            attachment.ParentId = Credit_approval.Id;
                            if (!bAttachment.fileName.endsWith('-2.pdf')) {
                              insert attachment;
                            }
                        }
                    }
                    result.success = true;
                    message = 'CreditApproval received:: '+ senders_ref +' EmailSubject:'+ emailSubject +' Successful...';

                } else if(tempstr == null && email.subject.contains('received')) {
                    message = 'CreditApproval Acknowledgement:'+ emailSubject +' Successful...';
                }
            }
            

        } catch (exception e) {
            database.rollback(sp);   
            System.debug(LoggingLevel.ERROR, 'Credit Approval Exception: '+e.getMessage());    
            System.debug(LoggingLevel.ERROR, 'Credit Approval Exception Stack: '+e.getStackTraceString());      
            //insert batch process log for exceptions
            message = 'CreditApprovalResponse: '+ senders_ref +'EmailSubject:'+ emailSubject 
                      +'Error:' +e.getmessage() +' LineNumber: '+ e.getlinenumber();
            result.success = false;
            result.message = 'Exception in processing the response at Salesforce end, error message is: ' + e.getmessage();
        } finally {
            insert new cllease__Batch_Process_Log__c(Name='ProcessCreditApprovalResponse: ',
            cllease__Date__c=system.today(), cllease__Message__c = message+' time: '+System.now());
        }
        return result;
    }
}