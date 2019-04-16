({
    doInit : function(component, event, helper) {

        component.set('v.columnsBalance', [
            {label: 'Previous', fieldName: 'chargeId', type: 'text'},
            {label: 'Amount Due', fieldName: 'feeAmount', type: 'text'}
           
        ]);
 
        component.set('v.columnsDue', [
            {label: 'Equipment', fieldName: 'equipmentName', type: 'text', initialWidth : 200,
            cellAttributes:{  
                class:{  
                    fieldName:"className"
                }
            }},
            {label: 'Charge/BIll Id', fieldName: 'recordName', type: 'text', initialWidth : 200,
            cellAttributes:{  
                class:{  
                    fieldName:"className"
                }
            }}, 
            {label: 'Description', fieldName: 'fee', type: 'text',  initialWidth : 200,
            cellAttributes:{  
                class:{  
                    fieldName:"className"
                }
            }},
            {label: 'Amount', fieldName: 'feeAmount', type: 'text',
            cellAttributes:{  
                class:{  
                    fieldName:"className"
                }
            }},
            {label: 'Tax', fieldName: 'taxAmount', type: 'text',
            cellAttributes:{  
                class:{  
                    fieldName:"className"
                }
            }},
            {label: 'Total', fieldName: 'totalAmount', type: 'text',
            cellAttributes:{  
                class:{  
                    fieldName:"className"
                }
            }
        }
           
        ]);

        component.set('v.columnsAdjustments', [
            {label: 'Equipment', fieldName: 'equipmentName', type: 'text', initialWidth : 200,
            cellAttributes:{  
                class:{  
                    fieldName:"className"
                }
            }},
            {label: 'Charge/BIll Id', fieldName: 'recordName', type: 'text', initialWidth : 200,
            cellAttributes:{  
                class:{  
                    fieldName:"className"
                }
            }}, 
            {label: 'Description', fieldName: 'fee', type: 'text',  initialWidth : 200,
            cellAttributes:{  
                class:{  
                    fieldName:"className"
                }
            }},
            {label: 'Amount', fieldName: 'feeAmount', type: 'text',
            cellAttributes:{  
                class:{  
                    fieldName:"className"
                }
            }},
            {label: 'Tax', fieldName: 'taxAmount', type: 'text',
            cellAttributes:{  
                class:{  
                    fieldName:"className"
                }
            }},
            {label: 'Total', fieldName: 'totalAmount', type: 'text',
            cellAttributes:{  
                class:{  
                    fieldName:"className"
                }
            }
        }
        ]);   
            
        component.set('v.columnsTotal', [
            {label: 'Total', fieldName: 'chargeId', type: 'text'},
            {label: 'Amount Due', fieldName: 'feeAmount', type: 'text'}
           
        ]);
        
        helper.fetchData(component,event);
        helper.fetchDataAdj(component,event);
        helper.fetchDataNewBillsAndCharges(component,event);


    }
})
