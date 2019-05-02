jQuery(function($) {
   var $modeElem = $("[name=TopicNamingMode]"),
       $set1 = $("[name=TopicNameTemplate]").parent(),
       $set2 = $("[name=TopicNameSource]").parent()
               .add($("[name=TopicNamePrefix]").parent())
               .add($("[name=TopicNameSuffix]").parent())
               .add($("[name=TopicNameTransliterate]").parents("div.foswikiFormStep:first"));

   function updateTopicNaming() {
      var val = $modeElem.filter(":checked").val();
      $set1.hide();
      $set2.hide();
      if (val === 'template') {
        $set1.fadeIn();
      } else if (val === 'derived') {
        $set2.fadeIn();
      } else {
         $modeElem.filter("[value=manual]").prop("checked", true);
      }
   }

   $modeElem.on("change", updateTopicNaming);
   updateTopicNaming();
});