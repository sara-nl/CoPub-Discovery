//global variables that can be used by ALL the function son this page.
var abstracts = new Array();
var titles = new Array();
var imgFalse = '/copub/copub/images/false.png';
var imgTrue = '/copub/copub/images/true.png';

function toggleAbstract() {
  var pubmed_id = arguments[0];
  var title = arguments[1];
  var abstract = arguments[2];
  
  if(abstracts[pubmed_id]) {
    document.getElementById('name_'+pubmed_id).value = abstracts[pubmed_id];
    abstracts[pubmed_id] ='';
    document.getElementById('img_'+pubmed_id).src=imgFalse;
    
    document.getElementById('title_'+pubmed_id).innerHTML = titles[pubmed_id];
    document.getElementById('abstract_'+pubmed_id).innerHTML = '';
  } else {
    abstracts[pubmed_id] = document.getElementById('name_'+pubmed_id).value;
    document.getElementById('name_'+pubmed_id).value = pubmed_id;
    document.getElementById('img_'+pubmed_id).src=imgTrue;
    titles[pubmed_id] = document.getElementById('title_'+pubmed_id).innerHTML;
    
    document.getElementById('title_'+pubmed_id).innerHTML = title;
    document.getElementById('abstract_'+pubmed_id).innerHTML = abstract;
  }
}  


// Dynamically create a form and convert args to hidden variables an submit the FORM
// This is used to bypass the 2083 character limit in Internet Explorer URL's 
// When a POST is used instead of a get the variables are not in the URL.
function openLink()
{
  var url = arguments[0];
  var args = arguments[1];
  var target = arguments[2];

  var submitForm=document.createElement("FORM");
  document.body.appendChild(submitForm);
  submitForm.method = "POST";

  var elArray = args.split('&');
  for(var i = 0; i < elArray.length; i++) {
    var element = elArray[i];
    var elKeyValue = element.split('=');
    if(elKeyValue.length == 2) {
      var newElement = document.createElement("INPUT");
      newElement.type = "hidden";
      newElement.name = elKeyValue[0];
      newElement.value = elKeyValue[1];
      submitForm.appendChild(newElement);
    }
  }
  submitForm.action= url;
  submitForm.target = target;
  submitForm.submit();
}
