We wil use the Logic App to showcase the feature at the Azure Portal.

It's a really simple process, and many times are not the developers that
are using this service (Business Logic). So, it' s important to show how 
easy is for non-tech people to create a powerfull workflow on top of 
usual and ready to use connectors and/or our own API's (e.g.: Timezone API).

Two simple major steps at the Azure Portal:
1 - Create the Twitter Connector;
2 - Create the Logic App:
  2.1 - Create the Trigger (using the Twitter Connector);
  2.2 - Create the Action to get the Date/Time (using the Timezone API);
  2.3 - Create the Action to tweet Date/Time and the Twitter User (using the Twitter Connector);

  Here the important part is the following configuration in the Tweet action (2.3 above):
  @concat('@', triggers().outputs.body.Tweeted_By, ' ', body('yourtimezoneorotherapi').time)

Soon I should add some screenshots and a more detailed howto for this, stay tuned!
