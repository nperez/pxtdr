use Test::More;
use MooseX::Declare;
use POE;

use POEx::Trait::DeferredRegistration;
use POEx::Role::SessionInstantiation
    traits => ['POEx::Trait::DeferredRegistration' => {method_name => 'foo'}];


my $test = 0;

class My::Session
{
    use POEx::Types(':all');
    with 'POEx::Role::SessionInstantiation';
    
    has started => (is => 'rw', isa => 'Bool', default => 0 );
    after _start is POEx::Role::Event {$self->started(1); $self->yield('fire')}
    
    method fire is POEx::Role::Event 
    {
        if(++$test < 2)
        {
            $self->yield('blah', My::Session->new(options => { trace => 1 }));
        }
    }

    method blah(DoesSessionInstantiation $session) is POEx::Role::Event
    {
        Test::More::is($session->started, 0, 'Session not started');
        $session->foo();
        Test::More::is($session->started, 1, 'Session successfully deferred');
    }
}

My::Session->new(options => { trace => 1 })->foo;
POE::Kernel->run();
done_testing();
1;
