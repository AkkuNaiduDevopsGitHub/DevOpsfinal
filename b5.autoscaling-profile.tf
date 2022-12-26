resource "azurerm_monitor_autoscale_setting" "web_vmss_autoscale" {
  name                = "${local.resource_name_prefix}-web-vmss-autoscale-profiles"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.web_vmss.id
  # Notification  
  notification {
      email {
        send_to_subscription_administrator    = true
        send_to_subscription_co_administrator = true
        custom_emails                         = ["gopal1409@gmail.com"]
      }
    }    
################################################################################
################################################################################
#######################  Profile-1: Default Profile  ###########################
################################################################################
################################################################################    
# Profile-1: Default Profile
  profile {
    name = "default"
  # Capacity Block    
    capacity {
      default = 2
      minimum = 2
      maximum = 6
    }
###########  START: Percentage CPU Metric Rules  ###########    
  ## Scale-Out
    rule {
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT5M"
      }            
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.web_vmss.id
        metric_namespace   = "microsoft.compute/virtualmachinescalesets"        
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
      }
    }

  ## Scale-In
    rule {
      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT5M"
      }        
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.web_vmss.id
        metric_namespace   = "microsoft.compute/virtualmachinescalesets"                
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }
    }
###########  END: Percentage CPU Metric Rules   ###########    

###########  START: Available Memory Bytes Metric Rules  ###########    
  ## Scale-Out
    rule {
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT5M"
      }            
      metric_trigger {
        metric_name        = "Available Memory Bytes"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.web_vmss.id
        metric_namespace   = "microsoft.compute/virtualmachinescalesets"        
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 1073741824 # Increase 1 VM when Memory In Bytes is less than 1GB
      }
    }

  ## Scale-In
    rule {
      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT5M"
      }        
      metric_trigger {
        metric_name        = "Available Memory Bytes"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.web_vmss.id
        metric_namespace   = "microsoft.compute/virtualmachinescalesets"                
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 2147483648 # Decrease 1 VM when Memory In Bytes is Greater than 2GB
      }
    }
###########  END: Available Memory Bytes Metric Rules  ###########  


###########  START: LB SYN Count Metric Rules - Just to Test scale-in, scale-out  ###########    
  ## Scale-Out
    rule {
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT5M"
      }      
      metric_trigger {
        metric_name        = "SYNCount"
        metric_resource_id = azurerm_lb.web_lb.id
        metric_namespace   = "Microsoft.Network/loadBalancers"        
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 10 # 10 requests to an LB
      }
    }
  ## Scale-In
    rule {
      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT5M"
      }      
      metric_trigger {
        metric_name        = "SYNCount"
        metric_resource_id = azurerm_lb.web_lb.id
        metric_namespace   = "Microsoft.Network/loadBalancers"                
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 10
      }
    }
###########  END: LB SYN Count Metric Rules  ###########    
  } # End of Profile-1


}
