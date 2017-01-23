"use strict";
jQuery(function($) {
   $(".fwbImageSelector").livequery(function() {
      var $selector = $(this);

      $selector.find("label").on("click", function() {
         var $this = $(this),
             isChecked = $this.find("input").prop("checked");

         $selector.find("input:checked").prop("checked", false);
         $selector.find(".selected").removeClass("selected");

         if (!isChecked) {
            $this.addClass("selected").find("input").prop("checked", true);
         }
         return false;
      });
   });
});