const cds = require('@sap/cds');

module.exports = cds.service.impl(async function() {
    const { Users, Reviews, SellerFeedbacks, Offerings } = this.entities;
    // validation
    this.before('CREATE', [Reviews, SellerFeedbacks], (req) => {
        const { rating } = req.data;
        if (rating < 1 || rating > 5) {
            return req.error(400, 'Рейтинг должен быть числом от 1 до 5');
        }
    });

//----------------------------------------------------
    // button logic
    this.on('setVIP', Users, async (req) => {
        const UserId = req.params[0].ID; 
        await UPDATE(Users).set({ status_code: 'VIP' }).where({ ID: UserId });
        req.notify('The status successfully changed to VIP');
        return await SELECT.one.from(Users).where({ ID: UserId });
    });

    this.on('setInactive', Users, async (req) => {
        const UserId = req.params[0].ID; 
        await UPDATE(Users).set({ status_code: 'INACTIVE' }).where({ ID: UserId });
        req.notify('The status changed to INACTIVE');
        return await SELECT.one.from(Users).where({ ID: UserId });
    });

    this.on('updateSellerRating', Users, async (req) => {
        const userId = req.params[0].ID; 
        
        const userData = await SELECT.one.from(Users).columns(u => {
            u.ID,
            u.feedbackOnSeller(f => { f.rating })
        }).where({ ID: userId });

        if (!userData) return req.error(404, 'User not found');

        let newRating = 0;
        const feedbacks = userData.feedbackOnSeller || [];

        if (feedbacks.length > 0) {
            const sum = feedbacks.reduce((total, fb) => total + (fb.rating || 0), 0);
            newRating = Number((sum / feedbacks.length).toFixed(1));
            
            if (newRating < 3) {
                await UPDATE(Users).set({
                    status_code: 'AT_RISK'
                }).where({ ID: userId });
            }
        }

        await UPDATE(Users).set({
            sellerRating: newRating,
            status_code: 'ACTIVE'
        }).where({ ID: userId });

        req.notify(`Rating successfully updated to ${newRating}`);
        return await SELECT.one.from(Users).where({ ID: userId });
    });

    this.on('updateOfferingRating', Offerings, async (req) => {
        const offerId = req.params[0].ID; 
        
        const offerData = await SELECT.one.from(Offerings).columns(o => {
            o.ID,
            o.reviews(r => { r.rating })
        }).where({ ID: offerId });

        if (!offerData) return req.error(404, 'Offering not found');

        let newRating = 0;
        const allReviews = offerData.reviews || [];

        if (allReviews.length > 0) {
            const sum = allReviews.reduce((total, rev) => total + (rev.rating || 0), 0);
            newRating = Number((sum / allReviews.length).toFixed(1));
        }

        await UPDATE(Offerings).set({
            averageRating: newRating
        }).where({ ID: offerId });

        req.notify(`Rating successfully updated to ${newRating}`);
        return await SELECT.one.from(Offerings).where({ ID: offerId });
    });

//-----------------------------------

    this.after('CREATE', Users, (each) => {
        console.log(`------------> New user: ${each.name} (${each.isSeller ? 'Seller' : 'Not Seller'})<-------------------------`);
    });

});