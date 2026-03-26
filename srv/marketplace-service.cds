using { my.game_marketplace as db } from '../db/schema';


service MarketplaceService {
    // for authenticated
    @requires: 'authenticated-user'
    @restrict: [
        { grant: ['READ', 'WRITE'], to: 'Admin' },
        { grant: ['READ'], to: 'SupportAgent' },
        { grant: ['READ', 'UPDATE'], to: 'User', where: 'email = $user' } 
    ]
    entity Users as projection on db.Users;

    // buy | sell interactions
    @requires: 'authenticated-user'
    @restrict: [
        { grant: ['*'], to: 'Admin' },
        { grant: ['READ', 'WRITE'], to: 'User', where: 'product.seller.email = $user' },
        { grant: ['READ'], to: 'User', where: 'buyer.email = $user AND isSold = true' }
    ]
    entity DigitalAssets as projection on db.DigitalAssets;


    // without authentication
    @restrict: [
        { grant: ['READ'], to: 'any' }, 
        { grant: ['WRITE'], to: 'User' },
        { grant: ['*'], to: 'Admin' }
    ]
    entity Products as projection on db.Products;

    // categories (games)
    @restrict: [
        { grant: ['READ'], to: 'any' },
        { grant: ['*'], to: 'Admin' }
    ]
    entity Categories as projection on db.Categories;

    // comments
    @restrict: [
        { grant: ['READ'], to: 'any' },
        { grant: ['CREATE'], to: 'User' },
        { grant: ['UPDATE', 'DELETE'], to: 'Admin' }
    ]
    entity Feedbacks as projection on db.Feedback;

}