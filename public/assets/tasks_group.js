function toggleUncompletedTask(t){var e=$(t).is(":checked");return link=e?$(t).parent().attr("data-complete-link"):$(t).parent().attr("data-uncomplete-link"),$(t).parent().parent(),$.ajax({type:"PUT",url:link}),!1}function toggleCompletedTask(t){var e=$(t).is(":checked");console.log(e),link=e?$(t).parent().attr("data-complete-link"):$(t).parent().attr("data-uncomplete-link");var n=$(t).parent().parent();return $.ajax({type:"PUT",url:link,success:function(){e?n.unwrap("<strike></strike>"):(n.wrap("<strike></strike>"),setTimeout(function(){move(n,$(".list-medium").first())},4e3))}}),!1}function move(t,e){t.toggle("highlight"),task_id=t.data("task-id"),new_source=e.find(t),new_source.toggle("highlight")}