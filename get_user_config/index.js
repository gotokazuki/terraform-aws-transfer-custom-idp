'use strict';

// GetUserConfig Lambda

exports.handler = (event, context, callback) => {
  console.log("Username:", event.username, "ServerId: ", event.serverId);

  var response;
  // Check if the username presented for authentication is correct. This doesn't check the value of the serverId, only that it is provided.
  if (event.serverId !== "" && event.username === process.env.userName) {
    response = {
      Role: process.env.userRoleArn, // The user will be authenticated if and only if the Role field is not blank
      Policy: '', // Optional JSON blob to further restrict this user's permissions
      HomeDirectory: process.env.userHomeDirectory // Not required, defaults to '/'
    };

    // Check if password is provided
    if (event.password === "") {
      // If no password provided, return the user's SSH public key
      response['PublicKeys'] = [ process.env.userPublicKey1 ];
      // Check if password is correct
    } else if (event.password !== process.env.userPassword) {
      // Return HTTP status 200 but with no role in the response to indicate authentication failure
      response = {};
    }
  } else {
    // Return HTTP status 200 but with no role in the response to indicate authentication failure
    response = {};
  }
  callback(null, response);
};
