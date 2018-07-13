/*
byLeal
July 2018
https://www.aroundcorners.com.br/blog/about.html

----------------------------------------------------------------------------------
NodeJS Function to Start an Azure Container Instance to execute short lived tasks.
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
    //These variables we need to have configured as App Settings values in Azure Portal...
    w_rgroup = process.env.WAKEUP_RGROUP;
    w_cname = process.env.WAKEUP_CNAME + '-' + min;
    w_cimage = process.env.WAKEUP_CIMAGE;
    w_clocation = process.env.WAKEUP_CLOCATION;
    w_costype = process.env.WAKEUP_COSTYPE;
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
            let container = new client.models.Container();

            //Container Properties...
            container.name = w_cname;
            container.image = w_cimage;
            container.ports = [{port: 80}];
            container.resources = {
                    requests: {
                        cpu: 1,
                        memoryInGB: 1
                     }
            };

            //Ok, let's do it!
            client.containerGroups.createOrUpdate(w_rgroup, w_cname,
                {
                    containers: [container],
                    osType: w_costype,
                    location: w_clocation,
                    restartPolicy: 'never'
                }).then((r) => {
                    context.log('Container launched Successfully');
                    context.log('Time to sleep... again!');
                    context.done();
                }).catch((r) => {
                    context.log('ERROR Lauching Container:', r);
                    context.done();
            });
    });
};
