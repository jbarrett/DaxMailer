#!/usr/bin/env perl

use FindBin;
use lib $FindBin::Dir . "/../lib";
use DaxMailer::Base::Web::Common;

schema->deploy_or_upgrade;

1;
