const cds = require('@sap/cds');

module.exports = cds.service.impl(async function() {
    const { Users, Reviews, SellerFeedbacks, Products } = this.entities;
    // validation
    this.before(['CREATE', 'UPDATE'], Reviews, (req) => {
        const data = req.data;
        if (!data.rating) {
            req.error(400, 'Rate the product', 'in/rating');
        }
        if (1 > data.rating || data.rating > 5 ) {
            req.error(400, 'Rating can be only from 1 to 5', 'in/rating');
        }
    });
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

    this.on('served', async () => {
        console.log('🔄 [System] Starting initial calculation of seller ratings...');
        
        // Достаем уникальные ID всех продавцов, на которых есть отзывы
        const sellers = await SELECT.distinct('seller_ID').from(SellerFeedbacks).where('seller_ID is not null');
        
        let count = 0;
        // Прогоняем каждого продавца через нашу готовую функцию
        for (const s of sellers) {
            await calcAndUpdateSellerRating(s.seller_ID);
            count++;
        }
        
        console.log(`✅ [System] Initial calculation complete! Updated ratings for ${count} sellers.`);
    })

    // calculating feedbacks on seller
    this.after(['CREATE', 'UPDATE', 'DELETE'], SellerFeedbacks, async (feedback, req) => {
        const sellerId = feedback?.seller_ID || req.data?.seller_ID; 
        if (!sellerId) return; 

        const allFeedbacks = await SELECT.from(SellerFeedbacks).where({ seller_ID: sellerId });

        let newRating = 0;
        let newStatus = 'ACTIVE';

        if (allFeedbacks.length > 0) {
            const sum = allFeedbacks.reduce((total, fb) => total + (fb.rating || 0), 0);
            newRating = Number((sum / allFeedbacks.length).toFixed(1));

            // At Risk status logic
            if (newRating < 3) {
                newStatus = 'AT_RISK';
            }
        }

        await UPDATE(Users).set({
            sellerRating: newRating,
            status_code: newStatus
        }).where({ ID: sellerId });
    });

    this.after(['CREATE', 'UPDATE', 'DELETE'], Reviews, async (review, req) => {
        const productId = review?.product_ID || req.data?.product_ID; 
        if (!productId) return; 

        const allReviews = await SELECT.from(Reviews).where({ product_ID: productId });

        let newRating = 0;

        if (allReviews.length > 0) {
            const sum = allReviews.reduce((total, rev) => total + (rev.rating || 0), 0);
            newRating = Number((sum / allReviews.length).toFixed(1));
        }

        await UPDATE(Products).set({
            averageRating: newRating
        }).where({ ID: productId });
    });

});