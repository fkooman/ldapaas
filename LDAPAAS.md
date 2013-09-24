# Introduction
This document describes a solution to the authentication and authorization 
problem of "virtual" or "collaborating" organizations.

Typically, in currently deployed identity federations for R&E a researcher or
student can authenticate to a service using a web browser. This is fine for 
situations where a web browser is available, but for some use cases this is not
an option as the tools that are being used are used on the command line (CLI) 
or require establishing secure shell (SSH) sessions to other hosts.

# Virtual Organizations
A Virtual Organization (VO) or Collaborating Organization (CO) is defined as a 
collection of researchers from various organizations under different sovereign
administrative realms. The researchers want to use the same instance of a 
service for collaborating purposes. 

# Use Case
As an example, the following use case can demonstrate the issues with currently
"web-only" identity federations.

A group of researchers want to share a number of documents amongst themselves. 
The researchers work at various institutes throughout the world. They each have
an account at their respective organization and are all connected to a 
"web-only" identity federation.

The researchers want to use their browser to access the files, a desktop client
for easy access and drag&drop and mobile applications on their mobile devices.

Current "web-only" identity federations rule out the use of desktop clients and
mobile applications. There is some work done to make this possible, but will 
require (extensive) modification of the applications and services involved.

# Goal
The goal is to allow researchers to authenticate to services in "non-web" 
scenarios where a web browser is not necessarily always available or 
convenient. So, in addition to accessing files using the web browser also 
mobile applications and desktop application must be usable with the minimum 
amount of modification and configuration required.

# Requirements
The following feature are required of the solution:

* **No direct access to user directory**: some institutes object to software 
  requiring direct access to their user directory, e.g. LDAP. So a solution is
  not allowed to require direct access to the user directory, but needs to be 
  wrapped to SAML or RADIUS;
* **Multi domain**: the solution needs to support multiple user directories 
  allowing for cross domain/realm access to one instance of a provided service;
* **IdP credentials**: in order to access the services the "home institute" 
  credentials should be used in order to gain access;
* **Non invasive**: the solution needs to have a low invasion of current 
  deployed software, i.e.: require the least amount of modification to server 
  and client;
* **Attributes**: the software should have access to attributes of the user, 
  e.g.: their display name and email address;
* **Provisioning**: ideally the user accounts in the service are created 
  automatically without an administrator needing to provision them manually;
* **Deprovisioning**: ideally the user account also needs to be able to be 
  removed when the user is no longer working in the VO and ceases to have 
  access to the service;
* **Secure**: the solution should be secure, i.e.: it should be impossible for
  3rd party observers to learn anything about or interfere with the 
  authentication and authorization of a particular user;
* **Usable**: the solution needs to be usable, i.e.: not differ from flows users
  are accustomed to;
* **Service has no access to password**: the password of the user should be 
  invisible or useless to the service;
* **Complexity**: the architecture should be simple, easy to understand and 
  verify, based on as many "standard" components as possible;
* **Maturity**: makes use a mature software and protocols that proved 
  themselves over the years;
* **Scalability**: solution should scale well when increasing the number of 
  users and services;
* **Interoperability**: should work with most existing available services;
* **Authorization**: solution should be able to authorize certain users for
  certain services, e.g.: user X can access service S, but not service T.

# Architecture
The idea behind LDAPAAS is that a VO specific LDAP is created where a user can
manage their own account by adding SSH public keys, client certificates and 
application specific passwords. There will be a VO administrator to approve 
accounts and link them to specific applications. 

To bootstrap the user accounts a connection is made to an identity federation 
like SURFconext to filter users that are allowed to create an account in the 
first place. This is optional and could also be replaced with a "free for all" 
registration form where a token, provided by the VO administrator, can be used
to prove the relation with the VO. However, reusing existing accounts has some 
benefits as it will reduce the administrative load on the VO.

                                       |
    +-----+                            |                         +---------+
    | IdP +------------+               |            +------------+ Service |
    +-----+            |               |            |            +---------+
                    +--+---------+     |     +------+--+
    +-----+         | SAML       |     |     | LDAPAAS |         +---------+
    | IdP +---------+ Identity   +-----|-----+         +---------+ Service |
    +-----+         | Federation |     |     |         |         +---------+
                    +--+---------+     |     +------+--+
    +-----+            |               |            |            +---------+
    | IdP +------------+               |            +------------+ Service |
    +-----+                            |                         +---------+
                                       |


# Flow
First the initial flow (on first login) will be shown, then the flow for future 
use of the services.

# Enrollment Flow
1. The user uses their web browser to go to the "enrollment portal" at 
   `https://vo.example.org`;
2. The authentication to this service is provided through a SAML authentication 
   flow to an identity federation;
3. After the user authenticates they are redirected back to the enrollment 
   portal;
4. Either attributes from the identity federation are used, or the user is 
   allowed to choose their own user identifier and display name and configure
   it manually.

Here, the user needs to wait to be approved by the VO administrator. Or in case
tokens are provided to all VO members the token can be used to show that the 
just created account is an approved account. Also, the services the user is 
allowed to access need to be determined and set. Now the flow continues after 
the user is approved:

1. The user uploads a SSH public key to a form to allow access to SSH 
   resources;
2. An LDAP account is created with the attributes the user provided and the SSH
   public key

Now the user can use the services without needing to go back to the enrollment 
portal.

# Regular Flow
In case the VO wants to make sure the users are still a member of any of the
configured identity providers the LDAP account can be marked as "expiring" and
require a "refresh" visit to the enrollment portal after a reasonable amount of 
time. Maybe every month, half a year or a year.
