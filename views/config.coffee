env = {
  sc_client_id: '2b9312964a1619d99082a76ad2d6d8c6'
}
env.pomotime =  if localStorage['is_dev'] then 0.1 else 24

if location.href.match(/245cloud.com/)
  env.parse_app_id = 'jemiGIUHsvNeVQojqiUaXxFJZvzFDxFbUsfjPr78'
  env.parse_key = 'ZoyMZflFV5H2VoASJv505vJ2wWd9zqa2ZW5MU780'
  env.facebook_app_id = '275431199325537'
else if location.href.match(/nishikocloud-c9.herokuapp.com/)
  env.parse_app_id = 'jemiGIUHsvNeVQojqiUaXxFJZvzFDxFbUsfjPr78'
  env.parse_key = 'ZoyMZflFV5H2VoASJv505vJ2wWd9zqa2ZW5MU780'
  env.facebook_app_id = '296210843914239'
else if location.href.match(/245cloud-c9-pandeiro245.c9.io/)
  env.parse_app_id = 'FbrNkMgFmJ5QXas2RyRvpg82MakbIA1Bz7C8XXX5'
  env.parse_key = 'yYO5mVgOdcCSiGMyog7vDp2PzTHqukuFGYnZU9wU'
  env.facebook_app_id = '287966291405361'

@env = env