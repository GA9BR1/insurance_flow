import { group, check } from 'k6';
import http from 'k6/http';

import { faker } from '@faker-js/faker/locale/en_US';

const generateTestData = () => ({
    endCoverageDate: faker.date.future().toISOString().split('T')[0],
    value: faker.finance.amount({ min: 500, max: 5000, dec: 0 }),
    name: faker.person.fullName(),
    cpf: faker.helpers.replaceSymbols('###########'),
    email: faker.internet.email(),
    vehicleBrand: faker.vehicle.manufacturer(),
    vehicleModel: faker.vehicle.model(),
    vehicleYear: faker.date.past({ years: 20 }).getFullYear().toString(),
    vehiclePlate: faker.string.alphanumeric(7).toUpperCase()
});

const NUMBER_OF_VUS = 60;

export const options = {
    cloud: {
        projectID: 3694185,
        name: 'Teste Insurance Solicitation-2-only-req'
    },
    scenarios: {
        request_policy_test: {          
            executor: 'per-vu-iterations',
            vus: NUMBER_OF_VUS,
            iterations: 10,
            maxDuration: '100s',
        }
    },
}

export function setup() {
    const login_page = http.get('http://localhost:3000/login');
    const csrf = login_page.html().find('input[name=authenticity_token]').attr('value');
    const login = http.request('POST', 'http://localhost:3000/authenticate', {
        authenticity_token: csrf,
        email: 'gustavoalberttodev@gmail.com',
        password: '123456'
    });
    return login.cookies['rack.session'];
}

export default async function(cookies) {
    const test_data = generateTestData();
    const vuJar = http.cookieJar();
    vuJar.set('http://localhost:3000/create_policy', 'rack.session', cookies[1]['Value'], 
        { 
            path: '/', domain: 'localhost', secure: false, httpOnly: true 
        }
    );

    group('User solicitates a policy creation sucessfully', async () => {
        const policy_create_page = http.get('http://localhost:3000/policies/new');
        const csrf = policy_create_page.html().find('input[name=authenticity_token]').attr('value');

        const response = http.post('http://localhost:3000/create_policy',
            {
                authenticity_token: csrf,
                'end-date': test_data.endCoverageDate,
                'prize-value': test_data.value,
                'full-name': test_data.name,
                'cpf': test_data.cpf,
                'email': test_data.email,
                'car-brand': test_data.vehicleBrand,
                'car-model': test_data.vehicleModel,
                'car-year': test_data.vehicleYear,
                'car-plate': test_data.vehiclePlate
            },
        );
        check(response, 
            {
                'is status 200': (r) => r.status === 200,
            }
        )
    });
}