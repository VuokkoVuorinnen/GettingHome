// the current open accordion will not be able to close itself
$('[data-toggle=\"collapse\"]').on('click',function(e){
    if ( $(this).parents('.accordion').find('.collapse.show') ){
        var idx = $(this).index('[data-toggle=\"collapse\"]');
        if (idx == $('.collapse.show').index('.collapse')) {
            e.stopPropagation();
        }
    }
});
