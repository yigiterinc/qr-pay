# qr-pay
Project developed for alternative-bank hackathon. This was a page that is designed to be embedded in bank's own app. We aimed to ease the payment process for visually impaired people. This is achieved with the help of a QR and voice command system. It works as follows: Client eats his/her meal in the restaurant, the waiter enters the price of order to their bank app, which is qrpaybank app in our case and the app generates a QR with price embedded in it. Client then opens their bank app's payment page holds their camera allowing waiter to show his QR to client's camera. Client app then asks for approval with voice from speakers, like "10 TL transaction request, do you confirm?" and after the client says "I confirm" it completes the transaction via the middleware.

Voice recognition and authentication was not completed but it was a planned feature for payment security. 

Project consists of 2 separate applications and 1 middleware. 
* qrpaybank: Client's app
* qrpayauth: Waiter's app in this example
* qrpaymid: Python Flask middleware that communicates with Bank API and forwards the responses
