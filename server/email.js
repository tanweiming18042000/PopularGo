const nodemailer = require('nodemailer');


async function sendMail(email, otpCode) {

    const html = "<h1> Hi Customer </h1> <p> The OTP code for your reset password is <b>" + otpCode + "</b></p>";

    var transport = nodemailer.createTransport({
        host: 'smtp.gmail.com',
        port: 465,
        secure: true,
        auth: {
            user: 'tanweiming18042000@gmail.com',
            pass: 'cmlakdalxvwqvtic',
        }
    });

    const info = await transport.sendMail({
        from: 'PopularGo <tanweiming18042000Agmail.com>',
        to: email,
        subject: 'Reset Password OTP',
        html: html,

    })
    console.log("Message sent: " + info.messageId);
}

module.exports = { sendMail };