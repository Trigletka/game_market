using { CrmService } from '../srv/service';

annotate CrmService.Users with @( 
UI.SelectionFields: [ 
name,
status_code, 
isSeller 
], 

UI.Identification: [ //backend buttons
{ $Type: 'UI.DataFieldForAction', Action: 'CrmService.setVIP', Label: 'Give VIP Status' },
{ $Type: 'UI.DataFieldForAction', Action: 'CrmService.setInactive', Label: 'Give Inactive Status' }  
],


UI.HeaderInfo: { // Page title in client 
TypeName: 'User', 
TypeNamePlural: 'Users', 
Title: { Value: name }
}, 

UI.LineItem: [ //columns 
    { $Type: 'UI.DataField', Value: name, Label: 'Nickname' }, 
    { $Type: 'UI.DataField', Value: email, Label: 'Email' },
    { $Type: 'UI.DataField', Value: phone, Label: 'Phone' },
    { $Type: 'UI.DataField', Value: status_code, Label: 'Status', Criticality: criticality }, 
    { $Type: 'UI.DataField', Value: isSeller, Label: 'Seller' }, 
    { $Type: 'UI.DataField', Value: sellerRating, Label: 'Rating' }
], 

UI.Facets: [ 
    { $Type: 'UI.ReferenceFacet', ID: 'GeneralFacet', Label: 'General Information', Target: '@UI.FieldGroup#General' }, 
    { $Type: 'UI.ReferenceFacet', ID: 'InteractionsFacet', Label: 'Interaction History', Target: 'interactions/@UI.LineItem' }, 
    { $Type: 'UI.ReferenceFacet', ID: 'PreferencesFacet', Label: 'Preferences', Target: 'preferences/@UI.LineItem' }, 
    { $Type: 'UI.ReferenceFacet', ID: 'SellerProductsFacet', Label: 'Offerings', Target: 'products/@UI.LineItem', }, 
    { $Type: 'UI.ReferenceFacet',ID: 'SellerFeedbacksFacet', Label: 'Seller Reviews',Target: 'feedbackOnSeller/@UI.LineItem'}
],

UI.FieldGroup #General: {
    Data: [
        { Value: email, Label: 'Email' },
        { Value: phone, Label: 'Phone' },
        { Value: isSeller, Label: 'Seller Account' },
        { Value: sellerRating, Label: 'Seller Rating' },
        {
        $Type: 'UI.DataField',
        Value: status_code,
        Label: 'Status',
        Criticality: criticality
        } 
    ] 
}
);

annotate CrmService.Users with {
    status @(
        Common.Label: 'Status',
        Common.ValueListWithFixedValues: true, 
        Common.ValueList: {
            CollectionPath: 'StatusTypes',
            Parameters: [
                { 
                    $Type: 'Common.ValueListParameterInOut', 
                    LocalDataProperty: status_code, 
                    ValueListProperty: 'code' 
                }
            ]
        }
    );
};

annotate CrmService.Interactions with @( 
UI.LineItem: [ 
{ Value: date, Label: 'Date' }, 
{ Value: type, Label: 'Type (Order/Chat)' }, 
{ Value: summary, Label: 'Subject' } 
], 

UI.HeaderInfo: { 
TypeName: 'Interaction', 
TypeNamePlural: 'Interactions', 
Title: { Value: summary }, 
Description: { Value: type } 
}, 

UI.Facets: [ 
{ 
$Type: 'UI.ReferenceFacet', 
ID: 'InteractionDetailsFacet', 
Label: 'Detailed information', 
Target: '@UI.FieldGroup#InteractionDetails' 
} 
], 

UI.FieldGroup #InteractionDetails: {
Data: [
{ Value: date, Label: 'Date and time' },
{ Value: type, Label: 'Communication channel' },
{
$Type: 'UI.DataFieldWithNavigationPath',
Value: user.name,
Label: 'User nickname',
Target: user
},

{ Value: user.email, Label: 'Contact email' },
{ Value: summary, Label: 'Subject' },
{ Value: description, Label: 'Full description of the conversation' }
]
}
);

annotate CrmService.Preferences with @(
    UI.LineItem: [
        { 
            $Type: 'UI.DataField', 
            Value: product.title,   // ← КЛЮЧЕВОЕ ИСПРАВЛЕНИЕ
            Label: 'Product',
            ![@UI.Importance]: #High
        },
        { 
            $Type: 'UI.DataField', 
            Value: product.price, 
            Label: 'Price' 
        }
    ]
);

annotate CrmService.Products with @( 
UI.HeaderInfo: { 
TypeName: 'Product', 
TypeNamePlural: 'Products', 
Title: { Value: title }, 
Description: { Value: description } 
}, 

UI.LineItem: [ 
{ $Type: 'UI.DataField', Value: title, Label: 'Product name' }, 
{ $Type: 'UI.DataField', Value: price, Label: 'Price' },{ $Type: 'UI.DataField', Value: stock, Label: 'In Stock' }
],

// Product page structure
UI.Facets: [
{
$Type: 'UI.ReferenceFacet',
ID: 'ProductDetails',
Label: 'Product Information',
Target: '@UI.FieldGroup#ProductGeneral'
},
{
$Type: 'UI.ReferenceFacet',
ID: 'SellerInfoFacet',
Label: 'Seller Contacts',
Target: '@UI.FieldGroup#SellerInfo'
},
{
$Type: 'UI.ReferenceFacet',
ID: 'ReviewsFacet',
Label: 'User Reviews',
Target: 'reviews/@UI.LineItem'
}
],

UI.FieldGroup #ProductGeneral: {
Data: [
{ Value: title, Label: 'Name' },
{ Value: price, Label: 'Price' },
{ Value: stock, Label: 'In stock' }
]
},

UI.FieldGroup #SellerInfo: {
Data: [
{ Value: seller.name, Label: 'Nickname' },
{ Value: seller.email, Label: 'Contact Email' }
]
}
);

annotate CrmService.Reviews with @(
UI.LineItem: [
{ Value: rating, Label: 'Rating (1-5)' },
{ Value: comment, Label: 'Comment' },
{ Value: author.name, Label: 'User Name' }
]
);

// columns for Seller Reviews
annotate CrmService.SellerFeedbacks with @( 
UI.LineItem: [ 
{ Value: leftBy.name, Label: 'From' }, 
{ Value: rating, Label: 'Rating' }, 
{ Value: comment, Label: 'Comment' }, 
{ Value: date, Label: 'Date' } 
]
);