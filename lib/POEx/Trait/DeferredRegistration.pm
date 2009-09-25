{package POEx::Trait::DeferredRegistration;}

#ABSTRACT: Provides deferred POE Session registration for SessionInstantiation objects

use MooseX::Declare;

role POEx::Trait::DeferredRegistration(Str :$method_name = 'register')
{
    with 'POEx::Role::SessionInstantiation::Meta::Session::Magic';

    around _post_build { $self->_overload_magic() }
    
    method "$method_name"#" 
    { 
        $self->_poe_register() 
    }
}

1;
__END__

=head1 SYNOPSIS

    class My::Session
    {
        use POEx::Trait::DeferredRegistration;
        use POEx::Role::SessionInstantiation
            traits => [ 'POEx::Trait::DeferredRegistration' ];

        with 'POEx::Role::SessionInstantiation';

        ....
    }

    ...
    # inside some event handler
    method some_event_handler is Event
    {
        my $session = My::Session->new();
        $self->yield('activate_session', session => $session);
    }

    method activate_session (DoesSessionInstantiation :$session) is Event
    {
        # Fiddle with the guts of $session prior to registration
        ...
        
        $session->register();

        # $session's _start will now be invoked within a POE context
    }


=head1 DESCRIPTION

POEx::Trait::DeferredRegistration provides a mechanism for instantiating
sessions without registering with POE immediately. It does this by reaching
into the guts of POEx::Role::SessionInstantiation::Meta::Session::Magic
and preventing BUILD from calling _poe_register (which calls session_alloc).

Simply call register on the session object at the appropriate time and it will
spring to life.

=head1 PARAMETERS

You can also alter the name of the name of the 'register' method by providing
a 'method_name' argument along with the trait name:

    use POEx::Role::SessionInstantiation
        traits =>
            ['POEx::Trait::DeferredRegistration' => { method_name => 'foo'}];
    ....
    $session->foo();
    # calls _poe_register()
