/*
byLeal
July 2018
https://www.aroundcorners.com.br/blog/about.html

----------------------------------------------------------------------------------
NodeJS Function to delete a Container Group for Short lived tasks.
----------------------------------------------------------------------------------
Based on the example written by R. Tyler: http://unethicalblogger.com
*/

module.exports = function (context) {
    const ACI = require('azure-arm-containerinstance');
    const AZ = require('ms-rest-azure');

    //When you interrupted our nap...
    var now = new Date();
    var min = now.getMinutes();

    context.log('We are awake!');

    //Some APP Settings Vars
    //These variables we MUST have configured as App Settings values in Azure Portal...
    w_rgroup = process.env.WAKEUP_RGROUP;
    w_cname = process.env.WAKEUP_CNAME;
    w_clocation = process.env.WAKEUP_CLOCATION;
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

            let client = new ACI(credentials, a_subscriptionid);

            /* First delete the previous existing container group if it exists */
            client.containerGroups.deleteMethod(w_rgroup, w_cname).then((r) => {

                }).then((r) => {
                    context.log('Container Group deleted Successfully');
                    context.log('Time to sleep... again!');
                    context.done();
                }).catch((r) => {
                    context.log('ERROR Deleting Container:', r);
                    context.done();
            });
    });
};
