using { CrmService } from '../srv/service';

annotate CrmService.Users with @( 
    UI.SelectionFields: [ 
        name,
        status_code, 
        isSeller 
    ], 

    UI.Identification: [ //backend buttons
        { $Type: 'UI.DataFieldForAction', Action: 'CrmService.setVIP', Label: 'Give VIP Status' },
        { $Type: 'UI.DataFieldForAction', Action: 'CrmService.setInactive', Label: 'Give Inactive Status' },
        { $Type: 'UI.DataFieldForAction', Action: 'CrmService.updateSellerRating', Label: 'Update Rating' }
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
        { $Type: 'UI.DataFieldForAnnotation', Target: '@UI.DataPoint#SellerRating', Label: 'Rating' },
    ], 

    UI.Facets: [ 
        { $Type: 'UI.ReferenceFacet', ID: 'GeneralFacet', Label: 'General Information', Target: '@UI.FieldGroup#General' }, 
        { $Type: 'UI.ReferenceFacet', ID: 'InteractionsFacet', Label: 'Interaction History', Target: 'interactions/@UI.LineItem' }, 
        { $Type: 'UI.ReferenceFacet', ID: 'WishlistFacet', Label: 'Wishlist', Target: 'wishlist/@UI.LineItem' }, 
        { $Type: 'UI.ReferenceFacet', ID: 'SellerOfferingsFacet', Label: 'Offerings', Target: 'offerings/@UI.LineItem', }, 
        { $Type: 'UI.ReferenceFacet', ID: 'SellerFeedbacksFacet', Label: 'Reviews on Seller',Target: 'feedbackOnSeller/@UI.LineItem'}
    ],

    UI.FieldGroup #General: {
        Data: [
            { Value: email, Label: 'Email' },
            { Value: phone, Label: 'Phone' },
            { Value: isSeller, Label: 'Seller Account' },
            { $Type: 'UI.DataFieldForAnnotation', Target: '@UI.DataPoint#SellerRating', Label: 'Seller Rating' },
            {
                $Type: 'UI.DataField',
                Value: status_code,
                Label: 'Status',
                Criticality: criticality
            } 
        ] 
    },

    UI.DataPoint #SellerRating: {
        Value: sellerRating,
        TargetValue: 5,
        Visualization: #Rating
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

annotate CrmService.Games with @( 
    UI.SelectionFields: [ 
        name,
        genre.name,
        description
    ], 

    UI.HeaderInfo: {
        TypeName: 'Game', 
        TypeNamePlural: 'Games', 
        Title: { Value: name }
    }, 

    UI.LineItem: [ //columns 
        { $Type: 'UI.DataField', Value: name, Label: 'Game Name' }, 
        { $Type: 'UI.DataField', Value: genre.name, Label: 'Genre' },
        { $Type: 'UI.DataField', Value: description, Label: 'Description' }
    ], 

    UI.Facets: [ 
        { $Type: 'UI.ReferenceFacet', ID: 'OfferingsFacet', Label: 'Offerings', Target: 'offerings/@UI.LineItem' },
    ]
);

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

    UI.Facets: [ { 
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

annotate CrmService.Wishlist with @(
    UI.LineItem: [
        { 
            $Type: 'UI.DataField', 
            Value: offering.title,
            Label: 'Offering',
            ![@UI.Importance]: #High
        },
        { 
            $Type: 'UI.DataField', 
            Value: offering.price, 
            Label: 'Price' 
        }
    ],

    UI.Facets: [
        { $Type: 'UI.ReferenceFacet', ID: 'WishlistFacet', Label: 'Wishlist', Target: 'offerings/@UI.LineItem' }
    ]
);

annotate CrmService.Genres with @(
    UI.HeaderInfo: {
        TypeName: 'Genre',
        TypeNamePlural: 'Genres',
    }
);


annotate CrmService.Offerings with @( 
    UI.Identification: [
        { $Type: 'UI.DataFieldForAction', Action: 'CrmService.updateOfferingRating', Label: 'Update Rating' }
    ],

    UI.HeaderInfo: { 
        TypeName: 'Offering', 
        TypeNamePlural: 'Offerings', 
        Title: { Value: title }, 
        Description: { Value: description } 
    }, 

    UI.LineItem: [ 
        { $Type: 'UI.DataField', Value: title, Label: 'Offering name' }, 
        { $Type: 'UI.DataField', Value: price, Label: 'Price' },{ $Type: 'UI.DataField', Value: stock, Label: 'Remaining' },
        { $Type: 'UI.DataFieldForAnnotation', Target: '@UI.DataPoint#OfferingRating', Label: 'Rating' },
    ],

    // Offering page structure
    UI.Facets: [
        {
            $Type: 'UI.ReferenceFacet',
            ID: 'OfferingDetails',
            Label: 'Offering Information',
            Target: '@UI.FieldGroup#OfferingGeneral'
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

    UI.FieldGroup #OfferingGeneral: {
        Data: [
            { Value: title, Label: 'Name' },
            { Value: price, Label: 'Price' },
            { Value: stock, Label: 'Remaining' },
            { Value: game.name, Label: 'Game' },
            { Value: genre.name, Label: 'Genre' },
            { $Type: 'UI.DataFieldForAnnotation', Target: '@UI.DataPoint#OfferingRating', Label: 'Rating' },
        ]
    },

    UI.FieldGroup #SellerInfo: {
        Data: [
            { Value: seller.name, Label: 'Nickname' },
            { Value: seller.email, Label: 'Contact Email' }
        ]
    },

    UI.DataPoint #OfferingRating: {
        Value: averageRating,
        TargetValue: 5,
        Visualization: #Rating
    }

);

annotate CrmService.Reviews with @(
    UI.LineItem: [
        { Value: rating, Label: 'Rating (1-5)' },
        { Value: comment, Label: 'Comment' },
        { Value: author.name, Label: 'User Name' }
    ]
);

annotate CrmService.SellerFeedbacks with @( 
    UI.LineItem: [ 
        { Value: leftBy.name, Label: 'From' }, 
        { Value: rating, Label: 'Rating' }, 
        { Value: comment, Label: 'Comment' }, 
        { Value: date, Label: 'Date' } 
    ]
);