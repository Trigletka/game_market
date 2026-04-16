const cds = require('@sap/cds');
const { GET, POST, axios } = cds.test(__dirname + '/..');

beforeAll(() => {
    if (axios.defaults.baseURL) {
        axios.defaults.baseURL = axios.defaults.baseURL.replace('localhost', '127.0.0.1');
    }
});

const authConfig = {
    auth: { username: 'admin', password: '11' }
};

describe('CrmService Unit Tests', () => {

    it('Must response user list (GET /Users)', async () => {
        const { data, status } = await GET('/crm/Users', authConfig);
        
        expect(status).toBe(200);
        expect(data.value).toBeDefined();
        expect(Array.isArray(data.value)).toBe(true);
    });

    it('Block rating > 5', async () => {
        const badReview = {
            rating: 10,
            comment: "No. We can't",
            offering_ID: "11111111-7777-8888-9999-000000000001" 
        };

        try {
            await POST('/crm/Reviews', badReview, authConfig);
            throw new Error('Nice');
        } catch (error) {
            if (!error.response) {
                console.error("Axios error:", error.message);
                throw error; 
            }
            
            expect(error.response.status).toBe(400);
            expect(error.response.data.error.message).toMatch(/From 1 to 5/);
        }
    });

});

const adminAuth = {
    auth: { username: 'admin', password: '11', roles: ['Admin'] }
};

const userAuth = {
    auth: { username: 'user', password: '11' }
};

describe('CrmService Authorization Tests', () => {

    let testUserId;

    beforeAll(async () => {
        const res = await GET('/crm/Users', adminAuth);
        testUserId = res.data.value[0].ID; 
    });

    it('Admin has access', async () => {
        const { status } = await POST(`/crm/Users(ID=${testUserId},IsActiveEntity=true)/CrmService.updateSellerRating`, {}, adminAuth);
        
        expect(status).toBe(200);
    });

    it('Casual user will receive 403 error', async () => {
        try {
            await POST(`/crm/Users(ID=${testUserId},IsActiveEntity=true)/CrmService.updateSellerRating`, {}, userAuth);
            throw new Error('Successful!');
        } catch (error) {
            if (!error.response) throw error;
            
            expect(error.response.status).toBe(403); 
        }
    });

});