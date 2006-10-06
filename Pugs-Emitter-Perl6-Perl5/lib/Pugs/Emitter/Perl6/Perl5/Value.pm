use strict;
use warnings;
# Compile-time Perl 5 thing, with hardcoded, autoboxed  methods

# operator name mangler:
# perl -MPugs::Runtime::Common -e ' print Pugs::Runtime::Common::mangle_ident("==") '

# TODO - List, Seq, ...

package Pugs::Emitter::Perl6::Perl5::Value;
    use base 'Pugs::Emitter::Perl6::Perl5::Any';
package Pugs::Emitter::Perl6::Perl5::Bool;
    use base 'Pugs::Emitter::Perl6::Perl5::Value';
    use overload (
        '""'     => sub { $_[0]->{name} ? '1' : '0' },
        fallback => 1,
    );
    sub WHAT { 
        $_[0]->node( 'Str', 'Bool' );
    }
    sub str {
        $_[0]->node( 'Str', ( $_[0]->{name} ? '1' : '0' ) );
    }
    sub int {
        $_[0]->node( 'Int', ( $_[0]->{name} ? '1' : '0' ) );
    }
    sub num {
        $_[0]->node( 'Num', ( $_[0]->{name} ? '1' : '0' ) );
    }
    sub perl {
        $_[0]->str;
    }
    sub true {
        $_[0]
    }
    sub not {
        $_[0]->{name} 
        ? $_[0]->node( 'Bool', 0 ) 
        : $_[0]->node( 'Bool', 1 )
    }
    ::unicode_sub 'infix:<==>', sub{ 
        $_[0]->int->infix_58__60__61__61__62_( $_[1] );
    };
package Pugs::Emitter::Perl6::Perl5::Str;
    use base 'Pugs::Emitter::Perl6::Perl5::Value';
    use overload (
        '""'     => sub { "'" . $_[0]->{name} . "'" },
        fallback => 1,
    );
    sub WHAT { 
        $_[0]->node( 'Str', 'Str' );
    }
    sub str {
        $_[0]
    }
    sub perl {
        $_[0]
    }
    sub num {
        $_[0]->node( 'Num', $_[0]->{name} + 0 );
    }
    sub int {
        $_[0]->num->int;
    }
    sub true {
        $_[0]->num->true;  # XXX
    }
    sub scalar {
        $_[0]->node( 'Perl5Scalar', 
            'bless \\' . $_[0]->perl . ", 'Pugs::Runtime::Perl6::Str'" 
        );
    }
    sub eq {
        $_[0]->node( 'BoolExpression', $_[0] . " eq " . $_[1]->str );
    }
package Pugs::Emitter::Perl6::Perl5::Int;
    use base 'Pugs::Emitter::Perl6::Perl5::Value';
    use overload (
        '""'     => sub { $_[0]->{name} },
        fallback => 1,
    );
    sub WHAT { 
        $_[0]->node( 'Str', 'Int' );
    }
    sub str {
        $_[0]->node( 'Str', $_[0]->{name} );
    }
    sub num {
        $_[0]->node( 'Num', $_[0]->{name} );
    }
    sub int {
        $_[0];
    }
    sub perl {
        $_[0]->str
    }
    ::unicode_sub 'infix:<==>', sub{ 
        $_[0]->num->infix_58__60__61__61__62_( $_[1] );
    };
package Pugs::Emitter::Perl6::Perl5::Num;
    use base 'Pugs::Emitter::Perl6::Perl5::Value';
    use overload (
        '""'     => sub { $_[0]->{name} },
        fallback => 1,
    );
    sub WHAT { 
        $_[0]->node( 'Str', 'Num' );
    }
    sub str {
        $_[0]->node( 'Str', $_[0]->{name} );
    }
    sub num {
        $_[0];
    }
    sub int {
        $_[0]->node( 'Int', int( $_[0]->{name} ) );
    }
    sub perl {
        $_[0]->str
    }
    ::unicode_sub 'infix:<==>', sub{ 
        my $tmp = $_[1]->num;
        return $_[0]->node( 'Bool', ( $_[0] == $tmp ) )
            if ref( $tmp ) eq 'Pugs::Emitter::Perl6::Perl5::Num';
        return $_[0]->node( 'BoolExpression', $_[0] . " == " . $tmp );
    };
package Pugs::Emitter::Perl6::Perl5::Code;
    use base 'Pugs::Emitter::Perl6::Perl5::Value';
    use overload (
        '""'     => sub { 'sub { ' . $_[0]->{name} . ' } ' },
        fallback => 1,
    );
    sub WHAT { 
        $_[0]->node( 'str', 'Code' );
    }
    sub str {
        $_[0]->node( 'str', $_[0]->{name} );
    }
    sub perl {
        $_[0]->str
    }
package Pugs::Emitter::Perl6::Perl5::Seq;
    use base 'Pugs::Emitter::Perl6::Perl5::Value';
    use overload (
        '""'     => sub { 
            '(' . join( ', ', @{$_[0]->{name}} ) . ')' 
        },
        fallback => 1,
    );
    sub WHAT { 
        $_[0]->node( 'str', 'Seq' );
    }
package Pugs::Emitter::Perl6::Perl5::Pair;
    use base 'Pugs::Emitter::Perl6::Perl5::Value';
    use overload (
        '""'     => sub { 
            '(' . join( ', ', @{$_[0]->{name}} ) . ')' 
        },
        fallback => 1,
    );
    sub WHAT { 
        $_[0]->node( 'str', 'Pair' );
    }

sub isa { 
    my $self = $_[0];
    return $self->other_get( $_[1] ) . ' eq ' . "'Pair'";  # hardcoded 
}

sub key {
    $_[0]->{key};
}

sub value {
    $_[0]->{value};
}

sub str {
    # TODO
}

sub perl {
    # TODO
}
    
sub defined {
    # TODO
}

sub kv {
    $_[0]->array
}

sub elems {
    return Pugs::Emitter::Perl6::Perl5::Perl5Scalar->new( {
        name => '1'
    } );
}

sub hash {
    # TODO
}

sub array {
    return Pugs::Emitter::Perl6::Perl5::Perl5Array->new( {
        name => '(' . $_[0]->key->name . ',' . $_[0]->value->name . ')'
    } );    
}

sub scalar {
    return Pugs::Emitter::Perl6::Perl5::Perl5Scalar->new( {
        name => 'bless {' . $_[0]->key->name . '=>' . $_[0]->value->name . "}, 'Pugs::Runtime::Perl6::Pair'" 
    } );
}

sub _123__125_ {
    # .{}
    my $self = $_[0];
    my $other = $self->other_get( $_[1] );
    return $_[0] unless $other;  # TODO
    return $self->dollar_name . '{' . $other . '}';
}

1;