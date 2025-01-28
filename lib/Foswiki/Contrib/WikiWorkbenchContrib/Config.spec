# ---+ Extensions
# ---++ WikiWorkbenchContrib

# **PERL EXPERT**
# This setting is required to enable executing the convertTopicType script from the tools directory
$Foswiki::cfg{SwitchBoard}{convertTopicType} = {
    package  => 'Foswiki::Contrib::WikiWorkbenchContrib',
    function => 'convertTopicType',
    context  => { convertTopicType => 1 },
};

1;
