namespace my.game_marketplace;

using { cuid, managed } from '@sap/cds/common';

entity Users : cuid, managed {
    name : String(50) @mandatory;
    email : String(100) @assert.format: '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    phone : String(20);
    isSeller : Boolean default false;
    avgRating : Decimal(3,2);
    interactions : Composition of many Interactions on interactions.user = $self;
    preferences : Association to many Preference on preferences.user = $self;
    feedbacksGiven : Association to many Feedback on feedbacksGiven.author = $self;
    feedbacksRcvd : Association to many Feedback on feedbacksRcvd.targetUser = $self;
}

// wishlist
entity Preference : cuid {
    user : Association to Users;
    productWished : Association to Products; // wished key (user saves product to buy it later)
}

// rating system
entity Feedback : cuid, managed {
    author : Association to Users; 
    targetUser : Association to Users; 
    product : Association to Products;  
    isPositive : Boolean; // feedback type (positive/negative)
    comments : String;
    feedbackDate : DateTime;
}

// what user can do
entity Interactions : cuid, managed {
    us : Association to Users;
    code : String(50);   // ('ORDER', 'DISPUTE' etc.)
    date : DateTime;
    summary : String(100);
    description : LargeString;
}

entity Categories : cuid {
    name : String(100);
    description : String;
}

entity Products : cuid, managed {
    seller : Association to Users;
    category : Association to Categories;
    title : String(150) @mandatory;
    description : LargeString;
    price : Decimal(10,2) @mandatory @assert.range: [0.01, 99999.99]; // NOT NULL & not negative
    currency : String(3) default 'USD';
    isActive : Boolean default true;
    assets : Composition of many DigitalAssets on assets.product = $self;
}

// entity for assets
entity DigitalAssets : cuid, managed {
    product : Association to Products;
    assetType : String(50) @mandatory ;
    assetData : LargeString @mandatory; 
    isSold : Boolean default false;
    buyer : Association to Users; 
}