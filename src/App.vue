<template>
  <div id="app">
    <p>Hi, everyone!</p>
    <p>To use this site, Please use ropsten test net with metamask.</p>
    <p>By this DApps, you can buy and sell ERC721 tokens anything. First, try to create your ERC721 token, and then click create token tab. The Transcation time is about 30 seconds.</p>
    <p>Adding first minted address on the card, the card can show unique information to the user. Also, if you want to delete your token, then click burn button in your MY TOKEN COLLECTION.</p> 
    <p>Next I will add rental and auction functions. Please look forward to it!</p>
    <div class="center">
      <el-tabs v-model="activeName" @tab-click="handleClick">
        <el-tab-pane label="CREATE TOKEN" name="first"></el-tab-pane>
        <el-tab-pane label="TOKEN MARKET" name="second"></el-tab-pane>
        <el-tab-pane label="MY TOKEN COLLECTION" name="third"></el-tab-pane>
      </el-tabs>
    </div>
    <router-view>
    </router-view>
    <el-footer>Copyright© 2018 <a href="https://github.com/rjoshima/tokenMarket" target="_blank">Joh</a> All Rights Reserved.</el-footer>
  </div>
</template>


<script>
  export default {
    data() {
      return {
        name: 'App',
        activeName: 'first'
      };
    },
    methods: {
      handleClick(tab, event) {
        console.log(tab);
        console.log(event)
        if (tab.name === "first") {
          this.$router.push('/')
        }
        if (tab.name === "second") {
          this.$router.push('/Market')
        }
        if (tab.name === "third") {
          this.$router.push('/MyCollection')
        }
      }
    }
  };
</script>

<style scoped>
  #app {
    font-family: 'Avenir', Helvetica, Arial, sans-serif;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    text-align: center;
    color: #2c3e50;

    font-size: 15px;
    padding: 90px 50px;
    background-color: white !important;
     
  };
  .center {
     padding: 20px 50px;
  
  }

</style>