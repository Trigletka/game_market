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
    wishlist: Composition of many Wishlist on wishlist.user = $self; 
    
    offerings: Association to many Offerings on offerings.seller = $self; 

    leftFeedbacks: Association to many Reviews on leftFeedbacks.author = $self;
    feedbackOnSeller: Composition of many SellerFeedbacks on feedbackOnSeller.seller = $self;

}

entity Interactions : managed, cuid {
    user: Association to Users;
    type: String(20);
    summary: String(100);
    description: String(500); 
    date: DateTime; 
}

entity Wishlist : managed, cuid {
    user: Association to Users;
    offering: Association to Offerings;
}

entity StatusTypes : CodeList {
    key code: String(10); 
}


entity Genres : managed, cuid {
    name: String(50);
    description: String(400);
    offerings: Association to many Offerings on offerings.genre = $self;
}

entity Games : managed, cuid {
    name: String(100);
    description: String(1500);
    genre: Association to Genres;
    offerings: Association to many Offerings on offerings.game = $self;
}

entity Offerings : managed, cuid {
    title: String(100);
    description: String(1500);
    
    seller: Association to Users;
    
    price: Decimal(10,2);
    stock: Integer;
    region: String(40);
    averageRating: Decimal(2,1) default 0;

    game: Association to Games;
    genre: Association to Genres;
    reviews: Composition of many Reviews on reviews.offering = $self;
}

entity Reviews : managed, cuid {
    offering: Association to Offerings;
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