using { gamekeys.crm as db } from '../db/schema';

@path: '/crm'
@requires: 'authenticated-user'
service CrmService {
    @cds.search: {name, email, phone}
    @odata.draft.enabled
    
    entity Users as projection on db.Users {
        *, 
        // color statuses
        case 
            when status.code = 'ACTIVE' then 3    // green
            when status.code = 'VIP' then 3       // green
            when status.code = 'AT_RISK' then 1   // yellow
            when status.code = 'INACTIVE' then 4
            else 0
        end as criticality : Integer

    } actions {
        @(restrict: [{ to: ['Admin', 'SalesManager', 'SupportAgent'] }])
        action setInactive() returns Users;
        
        @(restrict: [{ to: ['Admin', 'SalesManager'] }])
        action setVIP() returns Users;

        @(restrict: [{ to: ['Admin', 'SalesManager', 'SupportAgent'] }])
        action updateSellerRating() returns Users;
    };

    entity Offerings as projection on db.Offerings actions {
        @(restrict: [{ to: ['Admin', 'SalesManager', 'SupportAgent'] }])
        action updateOfferingRating() returns Offerings;
    };
    entity Games as projection on db.Games;
    entity Wishlist as projection on db.Wishlist;
    entity Reviews as projection on db.Reviews;
    entity Interactions as projection on db.Interactions;
    entity UserNotes as projection on db.UserNotes;
    entity SellerFeedbacks as projection on db.SellerFeedbacks;

    @readonly entity Genres as projection on db.Genres;
    @readonly entity StatusTypes as projection on db.StatusTypes;
}

// RBAC

annotate CrmService with @(requires: [
    'Admin',
    'SalesManager',
    'SupportAgent'
]);

annotate CrmService.Users with @(restrict: [
    { grant: ['READ'], to: 'SupportAgent' },
    { grant: ['READ', 'UPDATE'], to: 'SalesManager' },
    { grant: ['*'], to: 'Admin' }
]);

annotate CrmService.Games with @(restrict: [
    {grant: ['READ'], to: 'SupportAgent'},
    { grant: ['READ', 'CREATE', 'UPDATE'], to: 'SalesManager' },
    { grant: ['*'], to: 'Admin' }
]);

annotate CrmService.Interactions with @(restrict: [
    { grant: ['READ'], to: 'SupportAgent' },
    { grant: ['READ', 'CREATE', 'UPDATE'], to: 'SalesManager' },
    { grant: ['*'], to: 'Admin' }
]);

annotate CrmService.UserNotes with @(restrict: [
    { grant: ['READ', 'CREATE', 'UPDATE'], to: ['SalesManager', 'SupportAgent'] },
    { grant: ['*'], to: 'Admin' }
]);

annotate CrmService.Offerings with @(restrict: [
    { grant: ['READ'], to: 'SupportAgent' },
    { grant: ['READ', 'DELETE', 'UPDATE'], to: 'SalesManager' },
    { grant: ['*'], to: 'Admin' }
]);

annotate CrmService.Reviews with @(restrict: [
    { grant: ['*'], to: ['Admin', 'SalesManager'] }
])
