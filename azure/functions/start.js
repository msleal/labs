/*
byLeal
July 2018
https://www.aroundcorners.com.br/blog/about.html

----------------------------------------------------------------------------------
NodeJS Function to Start a Virtual Machine.
----------------------------------------------------------------------------------
*/

module.exports = function (context) {
    const VM = require('azure-arm-compute');
    const AZ = require('ms-rest-azure');

    //When you interrupted our nap...
    var now = new Date();
    var min = now.getMinutes();

    context.log('We are awake!');

    //Some APP Settings Vars
    //These variables we MUST have configured as App Settings values in Azure Portal...
    w_rgroup = process.env.START_RGROUP;
    w_cname = process.env.START_CNAME;
    a_clientid = process.env.AZURE_CLIENTID;
    a_clientsecret = process.env.AZURE_CLIENTSECRET;
    a_tenantid = process.env.AZURE_TENANTID;
    a_subscriptionid = process.env.AZURE_SUBSCRIPTIONID;

    //Let's Authenticate...
    AZ.loginWithServicePrincipalSecret(
        a_clientid,
        a_clientsecret,
        a_tenantid,
        (err, credentials) => {
            if (err) {
                throw err;
            }

            let client = new VM(credentials, a_subscriptionid);

            /* Let's do our job... */
            client.virtualMachines.start(w_rgroup, w_cname).then((r) => {
                }).then((r) => {
                    context.log('Virtual Machine started Successfully');
                    context.log('Time to sleep... again!');
                    context.done();
                }).catch((r) => {
                    context.log('ERROR Starting Virtual Machine:', r);
                    context.done();
            });
    });
};
