namespace gamekeys.crm;

using { managed, cuid, sap.common.CodeList } from '@sap/cds/common'; 

entity Users : managed, cuid {
    name: String(30);
    email: String(100);
    phone: String(20);
    
    isSeller: Boolean default false; 
    status: Association to StatusTypes; 

    totalPurchases: Decimal(10,2) default 0; 
    sellerRating: Decimal(2,1);  

    interactions: Composition of many Interactions on interactions.user = $self; 
    preferences: Composition of many Preferences on preferences.user = $self; 
    
    products: Association to many Products on products.seller = $self; 

    leftFeedbacks: Association to many Reviews on leftFeedbacks.author = $self;
    feedbackOnSeller: Composition of many SellerFeedbacks on feedbackOnSeller.seller = $self;

}

entity Interactions : managed, cuid {
    user: Association to Users;
    type: String(20);  // ORDER, DISPUTE etc
    summary: String(100);
    description: String(500); 
    date: DateTime; 
}

entity Preferences : managed, cuid {
    user: Association to Users;
    product: Association to Products;
}

entity StatusTypes : CodeList {
    key code: String(10); 
}


entity Genres : managed, cuid {
    name: String(50);
    description: String(400);
    products: Association to many Products on products.genre = $self;
}

entity Games : managed, cuid {
    name: String(100);
    description: String(1500);
    genre: Association to Genres;
    products: Association to many Products on products.game = $self;
}

entity Products : managed, cuid {
    title: String(100);
    description: String(1500);
    
    seller: Association to Users;
    
    price: Decimal(10,2);
    stock: Integer;
    region: String(40);
    averageRating: Decimal(2,1) default 0;

    game: Association to Games;
    genre: Association to Genres;
    reviews: Composition of many Reviews on reviews.product = $self;
}

entity Reviews : managed, cuid {
    product: Association to Products;
    author: Association to Users; 
    rating: Integer;
    comment: String(500);
    date: DateTime;
}

entity SellerFeedbacks : managed, cuid {
    seller: Association to Users;
    leftBy: Association to Users;
    rating: Integer;     
    comment: String(500); 
    date: DateTime;
}

entity UserNotes : managed, cuid {
    user: Association to Users;
    noteTitle: String(50);
    note: String(1000);
}