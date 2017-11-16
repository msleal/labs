## ---------- USAGE EXAMPLES ----------

##POWERSHELL
### First we create the Resource Group
New-AzureResourceGroup -name AroundCornersWorldApp -Location "East US"

### Now we create the first API APP (in this template we will create the gateway and hosting plan).
New-AzureResourceGroupDeployment -Name AroundCornersWorldAppCityLocatorAPI -ResourceGroupName AroundCornersWorldApp -TemplateUri "https://raw.githubusercontent.com/msleal/arm_templates/master/nodejs_apiapp/azuredeploy.json" -TemplateParameterFile "c:\users\someuser\somedir\parameters_nodejs_apiapp.json"

### Next we create the second APP (at this time we already have the gateway and hosting plan, so we just need to reference it).
New-AzureResourceGroupDeployment -Name AroundCornersWorldAppTimezoneAPI -ResourceGroupName AroundCornersWorldApp -TemplateUri "https://raw.githubusercontent.com/msleal/arm_templates/master/timezone_apiapp/azuredeploy.json" -TemplateParameterFile "c:\users\someuser\somedir\parameters_timezone_apiapp.json" -hostingPlanId (Get-AzureAppServicePlan -ResourceGroupName aroundcornersworldapp).Id

### Last but not least, we create the frontend APP (WEB APP).
New-AzureResourceGroupDeployment -Name AroundCornersWorldAppFrontend -ResourceGroupName AroundCornersWorldApp -TemplateUri "https://raw.githubusercontent.com/msleal/arm_templates/master/frontend_webapp/azuredeploy.json" -TemplateParameterFile "c:\users\malea\someuser\somedir\parameters_frontend_webapp.json" -hostingPlanId (Get-AzureAppServicePlan -ResourceGroupName aroundcornersworldapp).Id

##XPLAT
