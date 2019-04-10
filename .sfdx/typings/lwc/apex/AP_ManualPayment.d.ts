declare module "@salesforce/apex/AP_ManualPayment.addPayment" {
  export default function addPayment(param: {recordId: any, checkNumber: any, checkAmount: any, paymentDate: any}): Promise<any>;
}
declare module "@salesforce/apex/AP_ManualPayment.addAdjustment" {
  export default function addAdjustment(param: {invoiceId: any, type: any, debit: any, credit: any}): Promise<any>;
}
