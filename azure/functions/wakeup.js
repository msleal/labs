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
    //These variables we MUST have configured as App Settings values in Azure Portal...
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

            //Other APP Settings Vars
            //The configuration of these variables are OPTIONAL as App Settings values in Azure Portal...
            //NOTE: If you do not need them as ENV Vars to pass into the container, ommit the followin block.
            container.environmentVariables = [
                {
                    "name": "USERNAME",
                    "value": process.env.WAKEUP_USERNAME
                },
                {
                    "name": "USERPASSWD",
                    'secretValue': process.env.WAKEUP_USERPASSWD
                },
                {
                    'name': 'HOSTADDR',
                    'value': process.env.WAKEUP_HOSTADDR
                },
                {
                    'name': 'SCREENRESOLUTION',
                    'value': process.env.WAKEUP_SCREENRESOLUTION
                }
            ];

            //Container Properties...
            container.name = w_cname;
            container.image = w_cimage;
            //container.ports = [{'port': 8080}];
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
                    //ipAddress: {'ports': [{'protocol': 'TCP', 'port': 8080}], 'type': 'Public', "dnsNameLabel": w_cname},
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
