{ ... }:
{
  users.users.johan = {
    isNormalUser = true;
    description = "Johan Yngman";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "plugdev"
      "audio"
      "ubridge"
    ];

    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDcWjSPo+Zu7PKsjPjnTqs7JsUUN3cjs8omPv7DklJbnwKnveAT8TpPlIZE996CptgbJ4AO8rWgiFhxSOrb+KQS4Aej7FQMj9gAcOwPZkdhTAoU2XbYnpFs5roId3+l+mNV/I3oGWCNfOcO4P2OaSXORkk2Gr2mc2lNJAYaWNrkOk68IDZiWjHMbA/JYZMzGSKTyytOAWyVvN1hs5YPrPektyT+r/YbVPxOYrQnK9udBC6/xMt2pvjpdUtnwXsRYBaCXVNQKm9ptASSBA1sVsYByf2KZRaQgV+E7lT9tqwvYlKbVvIcdnvW303GHNl7mAaVb5MtQ67v6TG4CPOK4GJJIJKjsXQYHE8HUioGgZx00OCw7iRJ3WwEKh0VV6FpYiKPVXHSgZSql2e+EXDB7gxK0OC6gdNDGZvLP9OhUWFZBlWm/vFAivsfLWgPT2ARurso7oIntkprwnNwt4XI4khYIFggjEPjHzw3Q+C/ZgqVg9OcaZ8AOMANJ9X/O1F9NjnnXGfLbyvuDAdkjO8zwESaieUZ8jbZqBWdwL3q1IiYAUn9ibKZlRP6pG7ECUSAPVyrDCllfCvLRMSCOdge8xNKYZ0ugE2JPw4c2wyViN0ZIHISmBLDDl0/yADBE+e2yubCbND9J7kL8BkQwyduv7cbR+T06IataZIxn9doPiFD1w== johan@nixos"
    ];
  };
}
