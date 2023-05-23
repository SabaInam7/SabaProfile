//SPDX-License-Identifier: Unlicense
pragma solidity >=0.5.0 <0.9.0;

contract Inscrible {
    
    //USER STRUCT
    struct User{
        string username;
        friend[] friendList;
        //chawala
        Post [] myPosts;
        // string profilePic; do add later
    }

    struct AllUserStruck{
        string username;
        address accountAddress;
    }

    AllUserStruck[] AllUsers;
    
   struct friend{
        address pubkey;
        string name;
    }
    //POST COUNT
    uint postCount = 0;
    ///Friend list
   
    mapping(address=>Post[]) AllFriendPosts;

    //CONTAINING ALL THE POSTS UPLOADED BY USERS
    struct Post{
        string createrName;
        address payable userAddress;
        string imageHash;
        string caption;
        string imageText;
        uint256  tipAmount;
        uint256 id;
        uint likeCount;
        string [] likedByUser;
    }


    mapping(address=>User) userList;
    // User [] allRegisteredUsers;
    mapping(address=>Post[]) singleUserPostList;
    Post [] allposts;


    //FUNCTIONS----------------------------

    //CHECK IS A USER HAS AN ACCOUNT
    function checkUser(address key) public view returns(bool){
        if(AllUsers.length > 0)
        return bytes(userList[key].username).length > 0;
        else{
            return false;
        }
    }

    //GET USER NAME
    function getUsername(address key) public view returns(string memory){
        return userList[key].username;
    }

    //CREATE ACCOUNT
    function createAccount(string calldata _username) external {
        require(checkUser(msg.sender) == false, "User alredy has an account!");
        require(bytes(_username).length > 0, "User name should not be empty!");

        userList[msg.sender].username = _username;
        AllUsers.push(AllUserStruck(_username, msg.sender));
    }
    //addFriend
     function addFriend(address friend_key,string calldata name) external{
        require(checkUser(msg.sender), "Create an account first");
        require(checkUser(friend_key), "User is not registered!");
        require(msg.sender != friend_key, "Users cannot add themeselves as friends");
        require(checkAlreadyFriends(msg.sender,friend_key)== false, "These users are already friends");

         //_addFriend(msg.sender, friend_key, name);
          _addFriend(friend_key, msg.sender, userList[msg.sender].username);
         for(uint256 i=0;i<userList[friend_key].myPosts.length;i++)
         {
            singleUserPostList[msg.sender].push(userList[friend_key].myPosts[i]);
         }
    }
    //checkAlreadyFriend
    function checkAlreadyFriends(address sender_key,address friend_key) public view returns (bool){

        for(uint256 i = 0; i < userList[friend_key].friendList.length; i++){
            
            if(userList[friend_key].friendList[i].pubkey == sender_key) return true;
        }
        return false;
    }
    //_AddFriend
    function _addFriend(address friend_key, address me, string memory name) internal{
        friend memory newFriend = friend(me, name);
       userList[friend_key].friendList.push(newFriend);
    }

    //GETMY FRIEND
    function getMyFriendList() external view returns(friend[] memory){
        return userList[msg.sender].friendList;
    }

    //TO POST IMAGES TO BLOCKCHAIN
    function addPostImage(string memory _imgHash, string memory desc, string memory imgText) public 
    {   
        require(checkUser(msg.sender), "User not registered!");
        require(bytes(_imgHash).length > 0);
        postCount++;
        Post memory newPost = Post({
            createrName: userList[msg.sender].username,
            userAddress: payable(msg.sender),
            imageHash: _imgHash,
            caption: desc,
            imageText: imgText,
            tipAmount:0,
            id:postCount,
            likeCount:0,
            likedByUser : new string[](0)         
        });
            
        for(uint256 i = 0; i < userList[msg.sender].friendList.length; i++){
              singleUserPostList[userList[msg.sender].friendList[i].pubkey].push(newPost);
         } 
        userList[msg.sender].myPosts.push(newPost);
        // singleUserPostList[msg.sender].push(newPost);
        allposts.push(newPost);
        // _AllFriendPosts();
    }



    

    function getAllPosts() public view returns(Post [] memory){
        return allposts;
    }
    
   function getAllAppUser() public view returns(AllUserStruck[] memory){
        return AllUsers;
    }

    function getSingleUserPost(address key) public view returns(Post [] memory) {
        if (singleUserPostList[key].length > 0) {
            return singleUserPostList[key];
        } else {
            return new Post[](0);
        }
    }

    function getSingleUserLatestPost(address key) public view returns(Post memory){
        
            return  singleUserPostList[key][singleUserPostList[key].length-1]; 
        
    } 
    function removeFriend(address friendAddress) public {
        uint256 friendIndex;
        bool found = false;

        // Find the index of the friend in the array
        for (uint256 i = 0; i < userList[friendAddress].friendList.length; i++) {
            if (userList[friendAddress].friendList[i].pubkey == msg.sender) {
                friendIndex = i;
                found = true;
                break;
            }
        }
        // If the friend is found, remove it
        if (found) {
            // Replace the element at friendIndex with the last element
            userList[friendAddress].friendList[friendIndex] = userList[friendAddress].friendList[userList[friendAddress].friendList.length - 1];
            // Reduce the size of the array by one
            userList[friendAddress].friendList.pop();
    }
    }



    ////friends posts 

    //  function _AllFriendPosts()  internal {
    //     address friendAddress;
    //     Post [] memory postArray;
    //     require(userList[msg.sender].friendList.length >0, "You have no friends" );
    //     for (uint256 i = 0; i < userList[msg.sender].friendList.length; i++){
    //     friendAddress = userList[msg.sender].friendList[i].pubkey;
    //     postArray=getSingleUserPost(friendAddress);
    //     for (uint256 j = 0; j <postArray.length; j++){
    //         AllFriendPosts[msg.sender].push(postArray[j]);
    //     }
    //    }  
    // }

    //   function getAllFriendPosts() public view returns (Post[] memory){
    //      return AllFriendPosts[msg.sender];
    //    }

    
    receive() external payable {}
}