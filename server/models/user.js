const mongoose = require('mongoose');

const userSchema = mongoose.Schema({
    name: {
        type: String, 
        trim: true,
    },
    email: {
        type: String,
        trim: true,
        validate: {
            validator: (value) => {
                const re = /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/;
                return value.match(re);
            },
            message: 'Please enter a valid email address',
        },
    },
    password: {
        type: String,   
        validate: {
            validator: (value) => {
                return value.length > 6;
            },
            message: 'Please enter a long password',
        },
    },
    address: {
        type: String,
        default: "",
    }
});

// to convert a schema to a model
const User = mongoose.model('User', userSchema);
module.exports = User;