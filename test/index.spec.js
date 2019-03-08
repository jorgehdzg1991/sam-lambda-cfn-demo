const expect = require('expect');
const sinon = require('sinon');
const faker = require('faker');
const { sayHello } = require('../src/index');

describe('Demo app', () => {
    it('should say hello world', () => {
        const callback = sinon.fake();

        sayHello({}, null, callback);

        expect(callback.called).toEqual(true);

        const call = callback.getCall(0);

        expect(call.args[1]).toEqual({ greeting: 'Hello World!' });
    });

    it('should say hello to a user', () => {
        const callback = sinon.fake();
        const name = faker.name.firstName();

        sayHello({ name }, null, callback);

        expect(callback.called).toEqual(true);

        const call = callback.getCall(0);

        expect(call.args[1]).toEqual({ greeting: `Hello ${name}!` });
    });

    it('should error out if name is Slim Shady', () => {
        const callback = sinon.fake();
        const name = 'Slim Shady';

        sayHello({ name }, null, callback);

        expect(callback.called).toEqual(true);

        const call = callback.getCall(0);

        expect(call.args[0]).toEqual(
            'Will the real Slim Shady please stand up?'
        );
    });
});
