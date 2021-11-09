provider "azurerm"{
    features{}

    subscription_id = ""
    client_id	= ""
    client_secret	= ""
    tenant_id	= ""

}
#Resource Group Creation
resource "azurerm_resource_group" "myLinuxRg"{
    name=var.rgname
    location=var.location
}

#Vnet creation
resource "azurerm_virtual_network" "myLinuxVnet" {
    name                = var.vnetName
    address_space       = var.vnet_address_space
    location            = var.location
    resource_group_name = azurerm_resource_group.myLinuxRg.name
}

#subnet Creation
resource "azurerm_subnet" "myLinuxsubnet" {
    name                 = var.subnetName
    resource_group_name  = azurerm_resource_group.myLinuxRg.name
    virtual_network_name = azurerm_virtual_network.myLinuxVnet.name
    address_prefixes     = var.subnet_address_space
}

#NSG Creation with rule
resource "azurerm_network_security_group" "myNSG" {
    name                = var.NSGName
    location            = var.location
    resource_group_name = azurerm_resource_group.myLinuxRg.name

    security_rule {
        name                       = "SSH"
        priority                   = 200
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

}
resource "azurerm_subnet_network_security_group_association" "MyNSG-Subnet-association" {
  subnet_id                 = azurerm_subnet.myLinuxsubnet.id
  network_security_group_id = azurerm_network_security_group.myNSG.id
}

#Create Public IP 1
resource "azurerm_public_ip" "myPublicIP1" {
  name                = var.VM1PublicIPName
  resource_group_name = azurerm_resource_group.myLinuxRg.name
  location            = azurerm_resource_group.myLinuxRg.location
  allocation_method   = "Dynamic"

}

#Create Public IP 2
resource "azurerm_public_ip" "myPublicIP2" {
  name                = var.VM2PublicIPName
  resource_group_name = azurerm_resource_group.myLinuxRg.name
  location            = azurerm_resource_group.myLinuxRg.location
  allocation_method   = "Dynamic"

}

# Create network interface 1
resource "azurerm_network_interface" "myLinuxNIC1" {
    name                      = var.linux1NICName
    location                  = var.location
    resource_group_name       = azurerm_resource_group.myLinuxRg.name

    ip_configuration {
        name                          = "myNicConfiguration1"
        subnet_id                     = azurerm_subnet.myLinuxsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.myPublicIP1.id
    }

 
}

# Create network interface 2
resource "azurerm_network_interface" "myLinuxNIC2" {
    name                      = var.linux2NICName
    location                  = var.location
    resource_group_name       = azurerm_resource_group.myLinuxRg.name

    ip_configuration {
        name                          = "myNicConfiguration2"
        subnet_id                     = azurerm_subnet.myLinuxsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.myPublicIP2.id
    }

 
}


#create Virtual machine 1
resource "azurerm_linux_virtual_machine" "myLinuxVm1" {
    name                  = var.vm1Name
    location              = var.location
    resource_group_name   = azurerm_resource_group.myLinuxRg.name
    network_interface_ids = [azurerm_network_interface.myLinuxNIC1.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "myOsDisk1"
        caching           = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    admin_username = "azureuser"
    admin_password="azureUser@123"
    disable_password_authentication = false
    
    provisioner "remote-exec" {
        inline =   [
            "sudo apt update",
            "sudo apt install openjdk-11-jre-headless -y",
            "mkdir jenkins",
            "cd jenkins/",
            "wget https://get.jenkins.io/war-stable/2.303.1/jenkins.war",
            "java -jar jenkins.war &"
        ]
        connection {
            host = self.public_ip_address
            user =  self.admin_username
            password =  self.admin_password
        }
    }
}

#create Virtual machine 2
resource "azurerm_linux_virtual_machine" "myLinuxVm2" {
    name                  = var.vm2Name
    location              = var.location
    resource_group_name   = azurerm_resource_group.myLinuxRg.name
    network_interface_ids = [azurerm_network_interface.myLinuxNIC2.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "myOsDisk2"
        caching           = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    admin_username = "azureuser"
    admin_password="azureUser@123"
    disable_password_authentication = false

    provisioner "remote-exec" {
        inline =   [
            "sudo apt update",
            "sudo apt install openjdk-11-jre-headless -y",
            "sudo apt install -y maven",
            "sudo apt install -y docker*",
            "sudo apt install -y software-properties-common",
            "sudo add-apt-repository --yes --update ppa:ansible/ansible",
            "sudo apt update",
            "sudo apt install ansible -y",
            "sudo apt install git -y",
            "curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash",
            
        ]
        connection {
            host = self.public_ip_address
            user =  self.admin_username
            password =  self.admin_password
        }
    }
}