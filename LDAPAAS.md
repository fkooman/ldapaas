# Introduction
This document describes a possible solution to an authentication and 
authorization problem that occurs when one wants to make computing resources, 
e.g.: SSH, WebDAV or IMAP available to users located at various institutes in 
different administrative realms.

Typically, in currently deployed identity federations for R&E a researcher or
student can authenticate to a service using her web browser. This is fine for 
situations where a web browser is available and convenient, i.e. for web 
applications, but for some use cases this is not an option or very inconvenient 
to the user as the tools that are being used are used from the command line or 
require establishing secure shell (SSH) sessions to other hosts.

# Use Case
As an example, the following use case can demonstrate the issues with currently
"web-only" identity federations.

A group of researchers want to use a SSH service. The researchers work at 
various institutes throughout the world. They each have an account at their 
respective organization and are all connected to a "web-only" identity 
federation, typically using SAML.

The researchers want to use SSH to authenticate to the service. Current 
"web-only" identity federations rule out the use of such applications. There is 
some work done to make this possible, but will require (extensive) modification 
of the applications on both the client and server and requires changing 
users' behavior when using those applications.

# Goal
The goal is to allow researchers to authenticate to services in "non-web" 
scenarios where a web browser is not necessarily always available or 
convenient in such a way as to leverage existing accounts at the user' home 
institute.

# Requirements
The following characteristics are important to any potential solution to the 
mentioned problem:

* Simultaneously support user directories located in 
  **different administrative realms**, i.e.: researchers from institute X, Y 
  and Z.
* **Existing credentials** at the researcher's institute should be leveraged in
  order to regulate access to the services;
* Be **non-invasive** by requiring the least amount of changes to software, at
  both the server and client, and in the user's flow of using services;
* Optionally leverage existing **attributes** about the user from their 
  institute for access control or provisioning of user information;
* There should be no burden of **provisioning** on administrators or users of 
  the system, i.e.: accounts should be created on the fly;
* There should be no burden of **deprovisioning** on administrators of the 
  system. Accounts should be automatically removed when they are no longer in
  use.
* Must be **secure**, i.e.: it should be impossible for 3rd party observers to 
  learn anything about or interfere with the authentication and authorization 
  of a particular user;
* Needs to be **usable**, i.e: not differ (much) from flows users are currently 
  accustomed to;
* The credentials used should be **invisible** and **useless** to the service 
  processing them, i.e.: service X should not be able to use the credentials 
  somewhere else if they were ever leaked;
* The architecture should be **simple**, **straightforward** and easy to 
  **verify**;
* The used protocols and software should be **mature** and **well-tested**;
* Should **scale** when increasing the number of users, services
  and identity providers;
* Should **work with existing services** using well established protocols for
  authentication and authorization;
* Be able to **authorize** access to services based on the permissions for a 
  certain user;
* Should **leverage existing identity federations**, by only using the SAML 
  WebSSO profile.

# Architecture
The idea behind the proposed solution here is that a dedicated LDAP is created 
where a user can manage their own account by adding SSH public keys, X.509 
client certificates and application specific passwords. There may be an 
administrator to approve accounts and link them to specific applications. 
This could also be automated by using "just in time" provisioning.

To bootstrap the user accounts a connection is made to an identity federation 
like eduGAIN to filter users that are allowed to use the enrollment portal. 
This is optional and could also be replaced with a "free for all" 
registration form where optionally a token, distributed by the administrator 
through email for example, can be used to prove the user can have access. 
However, reusing existing accounts has some benefits as it will reduce the 
administrative load on for the administrator.

![Architecture](https://raw.github.com/fkooman/ldapaas/master/img/architecture.png)

# Flow
First the initial flow (on first login) will be shown, then the flow for future 
use of the services.

## Enrollment Flow
1. The user uses their web browser to go to the "enrollment portal" at 
   `https://portal.example.org`;
2. The authentication to this service is provided through a SAML authentication 
   flow to an identity federation;
3. After the user authenticates they are redirected back to the enrollment 
   portal;
4. Either attributes from the identity federation are used, or the user is 
   allowed to choose their own user identifier and display name and configure
   it manually;
5. An account is created in the LDAP service with a generated password to be 
   used with the services;
6. The user can in addition generate a SSH key (locally) and upload the public 
   component to the enrollment portal. Also a X.509 client certificate can be 
   generated and stored in the LDAP for access to services.
7. If a RADIUS proxy is made available additional services like 802.11x (WPA 
   enterprise) accounts can be made available to link the database to e.g. 
   eduroam.

After completing the steps the user may need to wait to be approved by an 
administrator. Or in case tokens are provided to all members the token can be 
used to show that the just created account is an approved account. Also, the 
services the user is allowed to access need to be determined and set. This 
information could also be provided through SAML attributes as part of an 
entitlement. Now the user can use the services without needing to go back to 
the enrollment portal.

## Using the Services Flow
In case the resource administrator wants to make sure the users are still a 
member of any of the configured identity providers the LDAP account can be 
marked as "expiring" and require a "refresh" visit to the enrollment portal 
after a reasonable amount of time. Maybe every month, half a year or a year.
