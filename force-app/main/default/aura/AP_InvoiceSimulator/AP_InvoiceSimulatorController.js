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
            {label: 'Amount', fieldName: 'feeAmount', type: 'currency', typeAttributes: { currencyCode: 'USD'},
            cellAttributes:{  
                class:{  
                    fieldName:"className"
                }
            }},
            {label: 'Tax', fieldName: 'taxAmount', type: 'currency', typeAttributes: { currencyCode: 'USD'},
            cellAttributes:{  
                class:{  
                    fieldName:"className"
                }
            }},
            {label: 'Total', fieldName: 'totalAmount', type: 'currency', typeAttributes: { currencyCode: 'USD'},
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
            {label: 'Amount', fieldName: 'feeAmount', type: 'currency', typeAttributes: { currencyCode: 'USD'},
            cellAttributes:{  
                class:{  
                    fieldName:"className"
                }
            }},
            {label: 'Tax', fieldName: 'taxAmount', type: 'currency', typeAttributes: { currencyCode: 'USD'},
            cellAttributes:{  
                class:{  
                    fieldName:"className"
                }
            }},
            {label: 'Total', fieldName: 'totalAmount', type: 'currency', typeAttributes: { currencyCode: 'USD'},
            cellAttributes:{  
                class:{  
                    fieldName:"className"
                }
            }
        }
        ]);   
            
        component.set('v.columnsTotal', [
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
            {label: 'Amount', fieldName: 'feeAmount', type: 'currency', typeAttributes: { currencyCode: 'USD'},
            cellAttributes:{  
                class:{  
                    fieldName:"className"
                }
            }},
            {label: 'Tax', fieldName: 'taxAmount', type: 'currency', typeAttributes: { currencyCode: 'USD'},
            cellAttributes:{  
                class:{  
                    fieldName:"className"
                }
            }},
            {label: 'Total', fieldName: 'totalAmount', type: 'currency', typeAttributes: { currencyCode: 'USD'},
            cellAttributes:{  
                class:{  
                    fieldName:"className"
                }
            }
        }
        ]);
        
        helper.fetchData(component,event);
        helper.fetchDataAdj(component,event);
         
        helper.fetchDataNewBillsAndCharges(component,event);


    }
})
