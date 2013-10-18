window.hello = ->
  document.getElementById('main').innerHTML = NES()

if window.addEventListener
  window.addEventListener('DOMContentLoaded', hello, false)
else
  window.attachEvent('load', hello)