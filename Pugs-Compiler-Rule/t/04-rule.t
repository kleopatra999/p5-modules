
use Test::More tests => 4;

use_ok( 'Pugs::Compiler::Rule' );

{
    my $rule = Pugs::Compiler::Rule->compile( '((.).)(.)' );
    my $match = $rule->match( "xyzw" );
    #print "Match: ", do{use Data::Dumper; Dumper($match)};
    is( eval { "$match" }, "xyz", 'stringify 1' );
    is( eval { "$match->[0]" }, "xy", 'stringify 2' );
    is( eval { "$match->[0][0]" }, "x", 'stringify 3' );
}

{
    *test::rule = Pugs::Compiler::Rule->compile( '((.).)(.)' )->code;
    my $match = test::rule->match( "xyzw" );
    is( eval { "$match" }, "xyz", 'stringify 1' );
}
