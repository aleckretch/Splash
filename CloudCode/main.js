Parse.Cloud.define("sendPushFavorited", function(request, response) {
                   var senderUsername = request.params.senderUsername;
                   var favoritedUsername = request.params.favoritedUsername;
                   var message = request.params.message;
                   
                   var pushQuery = new Parse.Query(Parse.Installation);
                   pushQuery.equalTo("username", favoritedUsername);
                   
                   Parse.Push.send({
                                   where: pushQuery,
                                   data: {
                                   alert: message
                                   }
                                   }).then(function() {
                                           response.success("Push was sent successfully.")
                                           }, function(error) {
                                           response.error("Push failed to send with error: " + error.message);
                                           });
                   });

Parse.Cloud.define("addViewer1", function(request, response) {
                   Parse.Cloud.useMasterKey();
                   var toUser = request.params.toUser;
                   
                   var query = new Parse.Query(Parse.User);
                   
                   query.equalTo("username", toUser);
                   query.first({
                               success: function(user){
                               var viewers = [];
                               var data = user.get("viewersTile1");
                               if(data)
                               {
                               viewers = data;
                               }
                               if (viewers.indexOf(request.params.fromUser) < 0)
                               {
                               viewers.push((request.params.fromUser));
                               }
                               user.set("viewersTile1", viewers);
                               user.save();
                               
                               var viewers = user.get("viewersTile1");
                               
                               response.success(viewers);
                               },
                               
                               error: function(error) {
                               console.error(error);
                               response.error("An error occured while looking up the username");
                               }
                               
                               });
                   });

Parse.Cloud.define("addViewer2", function(request, response) {
                   Parse.Cloud.useMasterKey();
                   var toUser = request.params.toUser;
                   
                   var query = new Parse.Query(Parse.User);
                   
                   query.equalTo("username", toUser);
                   query.first({
                               success: function(user){
                               var viewers = [];
                               var data = user.get("viewersTile2");
                               if(data)
                               {
                               viewers = data;
                               }
                               if (viewers.indexOf(request.params.fromUser) < 0)
                               {
                               viewers.push((request.params.fromUser));
                               }
                               user.set("viewersTile2", viewers);
                               user.save();
                               
                               var viewers = user.get("viewersTile2");
                               
                               response.success(viewers);
                               },
                               
                               error: function(error) {
                               console.error(error);
                               response.error("An error occured while looking up the username");
                               }
                               
                               });
                   });

Parse.Cloud.define("addViewer3", function(request, response) {
                   Parse.Cloud.useMasterKey();
                   var toUser = request.params.toUser;
                   
                   var query = new Parse.Query(Parse.User);
                   
                   query.equalTo("username", toUser);
                   query.first({
                               success: function(user){
                               var viewers = [];
                               var data = user.get("viewersTile3");
                               if(data)
                               {
                               viewers = data;
                               }
                               if (viewers.indexOf(request.params.fromUser) < 0)
                               {
                               viewers.push((request.params.fromUser));
                               }
                               user.set("viewersTile3", viewers);
                               user.save();
                               
                               var viewers = user.get("viewersTile3");
                               
                               response.success(viewers);
                               },
                               
                               error: function(error) {
                               console.error(error);
                               response.error("An error occured while looking up the username");
                               }
                               
                               });
                   });

Parse.Cloud.define("addViewer4", function(request, response) {
                   Parse.Cloud.useMasterKey();
                   var toUser = request.params.toUser;
                   
                   var query = new Parse.Query(Parse.User);
                   
                   query.equalTo("username", toUser);
                   query.first({
                               success: function(user){
                               var viewers = [];
                               var data = user.get("viewersTile4");
                               if(data)
                               {
                               viewers = data;
                               }
                               if (viewers.indexOf(request.params.fromUser) < 0)
                               {
                               viewers.push((request.params.fromUser));
                               }
                               user.set("viewersTile4", viewers);
                               user.save();
                               
                               var viewers = user.get("viewersTile4");
                               
                               response.success(viewers);
                               },
                               
                               error: function(error) {
                               console.error(error);
                               response.error("An error occured while looking up the username");
                               }
                               
                               });
                   });

Parse.Cloud.define("addViewer5", function(request, response) {
                   Parse.Cloud.useMasterKey();
                   var toUser = request.params.toUser;
                   
                   var query = new Parse.Query(Parse.User);
                   
                   query.equalTo("username", toUser);
                   query.first({
                               success: function(user){
                               var viewers = [];
                               var data = user.get("viewersTile5");
                               if(data)
                               {
                               viewers = data;
                               }
                               if (viewers.indexOf(request.params.fromUser) < 0)
                               {
                               viewers.push((request.params.fromUser));
                               }
                               user.set("viewersTile5", viewers);
                               user.save();
                               
                               var viewers = user.get("viewersTile5");
                               
                               response.success(viewers);
                               },
                               
                               error: function(error) {
                               console.error(error);
                               response.error("An error occured while looking up the username");
                               }
                               
                               });
                   });

Parse.Cloud.define("addViewer6", function(request, response) {
                   Parse.Cloud.useMasterKey();
                   var toUser = request.params.toUser;
                   
                   var query = new Parse.Query(Parse.User);
                   
                   query.equalTo("username", toUser);
                   query.first({
                               success: function(user){
                               var viewers = [];
                               var data = user.get("viewersTile6");
                               if(data)
                               {
                               viewers = data;
                               }
                               if (viewers.indexOf(request.params.fromUser) < 0)
                               {
                               viewers.push((request.params.fromUser));
                               }
                               user.set("viewersTile6", viewers);
                               user.save();
                               
                               var viewers = user.get("viewersTile6");
                               
                               response.success(viewers);
                               },
                               
                               error: function(error) {
                               console.error(error);
                               response.error("An error occured while looking up the username");
                               }
                               
                               });
                   });

Parse.Cloud.define("addViewer7", function(request, response) {
                   Parse.Cloud.useMasterKey();
                   var toUser = request.params.toUser;
                   
                   var query = new Parse.Query(Parse.User);
                   
                   query.equalTo("username", toUser);
                   query.first({
                               success: function(user){
                               var viewers = [];
                               var data = user.get("viewersTile7");
                               if(data)
                               {
                               viewers = data;
                               }
                               if (viewers.indexOf(request.params.fromUser) < 0)
                               {
                               viewers.push((request.params.fromUser));
                               }
                               user.set("viewersTile7", viewers);
                               user.save();
                               
                               var viewers = user.get("viewersTile7");
                               
                               response.success(viewers);
                               },
                               
                               error: function(error) {
                               console.error(error);
                               response.error("An error occured while looking up the username");
                               }
                               
                               });
                   });

Parse.Cloud.define("addViewer8", function(request, response) {
                   Parse.Cloud.useMasterKey();
                   var toUser = request.params.toUser;
                   
                   var query = new Parse.Query(Parse.User);
                   
                   query.equalTo("username", toUser);
                   query.first({
                               success: function(user){
                               var viewers = [];
                               var data = user.get("viewersTile8");
                               if(data)
                               {
                               viewers = data;
                               }
                               if (viewers.indexOf(request.params.fromUser) < 0)
                               {
                               viewers.push((request.params.fromUser));
                               }
                               user.set("viewersTile8", viewers);
                               user.save();
                               
                               var viewers = user.get("viewersTile8");
                               
                               response.success(viewers);
                               },
                               
                               error: function(error) {
                               console.error(error);
                               response.error("An error occured while looking up the username");
                               }
                               
                               });
                   });

Parse.Cloud.define("addViewer9", function(request, response) {
                   Parse.Cloud.useMasterKey();
                   var toUser = request.params.toUser;
                   
                   var query = new Parse.Query(Parse.User);
                   
                   query.equalTo("username", toUser);
                   query.first({
                               success: function(user){
                               var viewers = [];
                               var data = user.get("viewersTile9");
                               if(data)
                               {
                               viewers = data;
                               }
                               if (viewers.indexOf(request.params.fromUser) < 0)
                               {
                               viewers.push((request.params.fromUser));
                               }
                               user.set("viewersTile9", viewers);
                               user.save();
                               
                               var viewers = user.get("viewersTile9");
                               
                               response.success(viewers);
                               },
                               
                               error: function(error) {
                               console.error(error);
                               response.error("An error occured while looking up the username");
                               }
                               
                               });
                   });

Parse.Cloud.define("initialFavorites", function(request, response) {
                   var favorites = ["splash"];
                   response.success(favorites);
                   });

Parse.Cloud.define("incrementViewCount2", function(request, response) {
                   Parse.Cloud.useMasterKey();
                   var username = request.params.username;
                   
                   var query = new Parse.Query(Parse.User);
                   
                   query.equalTo("username", username);
                   query.first({
                               success: function(user){
                               user.set("countTile2", (request.params.views));
                               user.save();
                               
                               var count = user.get("countTile2");
                               response.success(count);
                               },
                               
                               error: function(error) {
                               console.error(error);
                               response.error("An error occured while looking up the username");
                               }
                               
                               });
                   });

Parse.Cloud.define("getFavorites", function(request, response) {
                   var username = request.params.username;
                   
                   var query = new Parse.Query(Parse.User);
                   query.equalTo("username", username);
                   query.first({
                               success: function(user){
                               var favorites = [];
                               var data = user.get("favorites");
                               if(data)
                               {
                               favorites = data;
                               }
                               
                               response.success(favorites);
                               },
                               
                               error: function(error) {
                               console.error(error);
                               response.error("An error occured while looking up the username");
                               }
                               
                               });
                   });

Parse.Cloud.define("getFavoritedBys", function(request, response) {
                   var username = request.params.username;
                   
                   var query = new Parse.Query(Parse.User);
                   query.equalTo("username", username);
                   query.first({
                               success: function(user){
                               var viewers = [];
                               var data = user.get("favoritedBys");
                               if(data)
                               {
                               viewers = data;
                               }
                               
                               response.success(viewers);
                               },
                               
                               error: function(error) {
                               console.error(error);
                               response.error("An error occured while looking up the username");
                               }
                               
                               });
                   });

Parse.Cloud.define("getUser", function(request, response) {
                   var username = request.params.username;
                   
                   var query = new Parse.Query(Parse.User);
                   query.equalTo("username", username);
                   query.first({
                               success: function(user){
                               
                               response.success(user);
                               },
                               
                               error: function(error) {
                               console.error(error);
                               response.error("An error occured while looking up the username");
                               }
                               
                               });
                   });

Parse.Cloud.define("getUserFromFacebook", function(request, response) {
                   var facebookId = request.params.facebookId;
                   
                   var query = new Parse.Query(Parse.User);
                   query.equalTo("fbId", facebookId);
                   query.first({
                               success: function(user){
                               
                               response.success(user);
                               },
                               
                               error: function(error) {
                               console.error(error);
                               response.error("An error occured while looking up the username");
                               }
                               
                               });
                   });

Parse.Cloud.define("getViewers1", function(request, response) {
                   var username = request.params.username;
                   
                   var query = new Parse.Query(Parse.User);
                   query.equalTo("username", username);
                   query.first({
                               success: function(user){
                               var viewers = [];
                               var data = user.get("viewersTile1");
                               if(data)
                               {
                               viewers = data;
                               }
                               
                               response.success(viewers);
                               },
                               
                               error: function(error) {
                               console.error(error);
                               response.error("An error occured while looking up the username");
                               }
                               
                               });
                   });

Parse.Cloud.define("getViewers2", function(request, response) {
                   var username = request.params.username;
                   
                   var query = new Parse.Query(Parse.User);
                   query.equalTo("username", username);
                   query.first({
                               success: function(user){
                               var viewers = [];
                               var data = user.get("viewersTile2");
                               if(data)
                               {
                               viewers = data;
                               }
                               
                               response.success(viewers);
                               },
                               
                               error: function(error) {
                               console.error(error);
                               response.error("An error occured while looking up the username");
                               }
                               
                               });
                   });

Parse.Cloud.define("getViewers3", function(request, response) {
                   var username = request.params.username;
                   
                   var query = new Parse.Query(Parse.User);
                   query.equalTo("username", username);
                   query.first({
                               success: function(user){
                               var viewers = [];
                               var data = user.get("viewersTile3");
                               if(data)
                               {
                               viewers = data;
                               }
                               
                               response.success(viewers);
                               },
                               
                               error: function(error) {
                               console.error(error);
                               response.error("An error occured while looking up the username");
                               }
                               
                               });
                   });

Parse.Cloud.define("getViewers4", function(request, response) {
                   var username = request.params.username;
                   
                   var query = new Parse.Query(Parse.User);
                   query.equalTo("username", username);
                   query.first({
                               success: function(user){
                               var viewers = [];
                               var data = user.get("viewersTile4");
                               if(data)
                               {
                               viewers = data;
                               }
                               
                               response.success(viewers);
                               },
                               
                               error: function(error) {
                               console.error(error);
                               response.error("An error occured while looking up the username");
                               }
                               
                               });
                   });

Parse.Cloud.define("getViewers5", function(request, response) {
                   var username = request.params.username;
                   
                   var query = new Parse.Query(Parse.User);
                   query.equalTo("username", username);
                   query.first({
                               success: function(user){
                               var viewers = [];
                               var data = user.get("viewersTile5");
                               if(data)
                               {
                               viewers = data;
                               }
                               
                               response.success(viewers);
                               },
                               
                               error: function(error) {
                               console.error(error);
                               response.error("An error occured while looking up the username");
                               }
                               
                               });
                   });

Parse.Cloud.define("getViewers6", function(request, response) {
                   var username = request.params.username;
                   
                   var query = new Parse.Query(Parse.User);
                   query.equalTo("username", username);
                   query.first({
                               success: function(user){
                               var viewers = [];
                               var data = user.get("viewersTile6");
                               if(data)
                               {
                               viewers = data;
                               }
                               
                               response.success(viewers);
                               },
                               
                               error: function(error) {
                               console.error(error);
                               response.error("An error occured while looking up the username");
                               }
                               
                               });
                   });

Parse.Cloud.define("getViewers7", function(request, response) {
                   var username = request.params.username;
                   
                   var query = new Parse.Query(Parse.User);
                   query.equalTo("username", username);
                   query.first({
                               success: function(user){
                               var viewers = [];
                               var data = user.get("viewersTile7");
                               if(data)
                               {
                               viewers = data;
                               }
                               
                               response.success(viewers);
                               },
                               
                               error: function(error) {
                               console.error(error);
                               response.error("An error occured while looking up the username");
                               }
                               
                               });
                   });

Parse.Cloud.define("getViewers8", function(request, response) {
                   var username = request.params.username;
                   
                   var query = new Parse.Query(Parse.User);
                   query.equalTo("username", username);
                   query.first({
                               success: function(user){
                               var viewers = [];
                               var data = user.get("viewersTile8");
                               if(data)
                               {
                               viewers = data;
                               }
                               
                               response.success(viewers);
                               },
                               
                               error: function(error) {
                               console.error(error);
                               response.error("An error occured while looking up the username");
                               }
                               
                               });
                   });

Parse.Cloud.define("getViewers9", function(request, response) {
                   var username = request.params.username;
                   
                   var query = new Parse.Query(Parse.User);
                   query.equalTo("username", username);
                   query.first({
                               success: function(user){
                               var viewers = [];
                               var data = user.get("viewersTile9");
                               if(data)
                               {
                               viewers = data;
                               }
                               
                               response.success(viewers);
                               },
                               
                               error: function(error) {
                               console.error(error);
                               response.error("An error occured while looking up the username");
                               }
                               
                               });
                   });

Parse.Cloud.define("addFavorite", function(request, response) {
                   var favoritedUsername = request.params.favoritedUsername;
                   var senderUsername = request.params.senderUsername
                   var query = new Parse.Query(Parse.User);
                   
                   query.equalTo("username", senderUsername);
                   query.first({
                               success: function(user){
                               var favorites = [];
                               var data = user.get("favorites");
                               if(data)
                               {
                               favorites = data;
                               }
                               if (favorites.indexOf(favoritedUsername) < 0)
                               {
                               favorites.push((favoritedUsername));
                               }
                               user.set("favorites", favorites);
                               user.save();
                               
                               response.success(favorites);
                               },
                               
                               error: function(error) {
                               console.error(error);
                               response.error("An error occured while looking up the username");
                               }
                               
                               });
                   
                   });

Parse.Cloud.define("addFavoritedBy", function(request, response) {
                   Parse.Cloud.useMasterKey();
                   var favoritedUsername = request.params.favoritedUsername;
                   var senderUsername = request.params.senderUsername
                   
                   var query = new Parse.Query(Parse.User);
                   
                   query.equalTo("username", favoritedUsername);
                   query.first({
                               success: function(user){
                               var favoritedBys = [];
                               var data = user.get("favoritedBys");
                               if(data)
                               {
                               favoritedBys = data;
                               }
                               if (favoritedBys.indexOf(senderUsername) < 0)
                               {
                               favoritedBys.push((senderUsername));
                               }
                               user.set("favoritedBys", favoritedBys);
                               user.save();
                               
                               response.success(favoritedBys);
                               },
                               
                               error: function(error) {
                               console.error(error);
                               response.error("An error occured while looking up the username");
                               }
                               
                               });
                   });

Parse.Cloud.define("removeFavorite", function(request, response) {
                   var favoritedUsername = request.params.favoritedUsername;
                   var senderUsername = request.params.senderUsername
                   var query = new Parse.Query(Parse.User);
                   
                   query.equalTo("username", senderUsername);
                   query.first({
                               success: function(user){
                               var favorites = [];
                               var data = user.get("favorites");
                               if(data)
                               {
                               favorites = data;
                               }
                               var index = favorites.indexOf(favoritedUsername);
                               if (index > -1)
                               {
                               favorites.splice(index, 1);
                               }
                               user.set("favorites", favorites);
                               user.save();
                               
                               response.success(favorites);
                               },
                               
                               error: function(error) {
                               console.error(error);
                               response.error("An error occured while looking up the username");
                               }
                               
                               });
                   
                   });

Parse.Cloud.define("removeFavoritedBy", function(request, response) {
                   Parse.Cloud.useMasterKey();
                   var favoritedUsername = request.params.favoritedUsername;
                   var senderUsername = request.params.senderUsername
                   
                   var query = new Parse.Query(Parse.User);
                   
                   query.equalTo("username", favoritedUsername);
                   query.first({
                               success: function(user){
                               var favoritedBys = [];
                               var data = user.get("favoritedBys");
                               if(data)
                               {
                               favoritedBys = data;
                               }
                               var index = favoritedBys.indexOf(senderUsername);
                               if (index > -1)
                               {
                               favoritedBys.splice(index, 1);
                               }
                               user.set("favoritedBys", favoritedBys);
                               user.save();
                               
                               response.success(favoritedBys);
                               },
                               
                               error: function(error) {
                               console.error(error);
                               response.error("An error occured while looking up the username");
                               }
                               
                               });
                   });