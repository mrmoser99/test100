({
    populateAddressFields: function(component, address){
        component.find('addressLine1').set('v.value', address.addressLine1);
        component.find('city').set('v.value', address.city);
        component.find('county').set('v.value', address.county);
        component.find('state').set('v.value', address.state);
        component.find('country').set('v.value', address.country);
        component.find('postalCode').set('v.value', address.postalCode);
        component.find('validStatus').set('v.value', address.validStatus);
        component.find('validTime').set('v.value', address.validTime);
    },
    isValid: function(address){
        if(!address.Address_Line_1__c || address.Address_Line_1__c == ''){
            return false;
        }else if(!address.City__c || address.City__c == ''){
             return false;
        }else if(!address.State__c || address.State__c == ''){
             return false;
        }else if(!address.County__c || address.County__c == ''){
             return false;
        }else if(!address.Zip_Code__c || address.Zip_Code__c == ''){
             return false;
        }else if(!address.Country__c || address.Country__c == ''){
             return false;
        }
        return true;
    }
})