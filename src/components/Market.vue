<template> 
  <div style="margin: 20px 10px 50px 10px;" v-loading="loading">
    <md-card v-for="(token, key, index) in tokens" :key="index" v-if="token.sell">      
        <md-card-media>
          <img src="../assets/usagi.png" v-if="token.sort==0">
          <img src="../assets/estate.png" v-if="token.sort==1" class="image-estate">
          <img src="../assets/ticket.png" v-if="token.sort==2">
          <img src="../assets/copyright.png" v-if="token.sort==3">
        </md-card-media>

        <md-card-header>
          <div class="md-title">{{ token.name | title_cut }}</div>
          <div class="md-subhead">ID : {{token.id}}</div>
          <div class="md-subhead">Minted by : {{token.minted}}</div>
        </md-card-header>

        <md-card-actions>
          <md-button class="md-raised" @click="quitSoldToken(token.id, token.true_price)" v-if="token.owner">Owner {{token.price}}eth Stop SELL</md-button>
          <md-button class="md-raised" @click="buyToken(token.id, token.true_price)" v-if="!token.owner">{{token.price}}eth Buy</md-button>
        </md-card-actions>

        <md-card-content>
          {{ token.details | details_cut }}
        </md-card-content> 
   </md-card>

      <md-dialog-alert
          :md-active.sync="ropsten"
          md-content="Alert: Use ropsten net( You can't use this function), check it https://qiita.com/tmikada/items/cdc5a3871f655cb7b67d"
          md-confirm-text="Cancel" />

       <md-dialog-alert
          :md-active.sync="txSuccess"
          :md-content="txUrl"
          md-confirm-text="Cancel" />  
  </div>
</template>

<script>
  import Web3 from 'web3'
  import contract from 'truffle-contract'
  import artifacts from '../../build/contracts/createToken.json'
  const CreateToken = contract(artifacts)
  export default {
    name: 'UserCollection',
    data () {
      return {
        tokens: [],
        ropsten: false,
        txSuccess: false,
        txUrl: "",
        loading: false,
        gasPrice: web3.toWei(2, "gwei"),
      }
    },
    async created () {

      try {
        web3 = await new Web3(web3.currentProvider)

        CreateToken.setProvider(web3.currentProvider)
        await web3.eth.getAccounts(async (err, accs) => {
          if (web3.currentProvider.publicConfigStore._state.networkVersion !== '3') {
            this.ropsten = true
            return
          } 
          this.account = accs[0];
          console.log(this.account)
          this.instance = await CreateToken.deployed()
          await this.updatetokens()
          await this.getGasPrice()

        })
      } catch (err) {
        console.log(err.message)
        this.ropsten = true
      }
       
    },
    methods: {
      async updatetokens() {
        try {
          this.tokens = []
          await this.instance.tokensOfAll().then(async (r) => {
            for (var i = 0; i < r.length; i++) {
              await this.gettoken(r[i]);
            }
          })
        } catch (err) {
          console.log(err.message);

        }
      },
      async gettoken(tokenId) {
        try {
          await this.instance.getToken(tokenId, { from: this.account }).then((r) => {
            let token = {}
            
            token["name"] = r[0];
            token["details"] = r[1];
            token["true_price"] = r[2];
            token["sell"] = r[3]
            token["owner"] = r[4] === this.account
            token["minted"] = r[5];
            token["price"] = parseFloat(web3.fromWei(r[2], "ether"))
            token["id"] = parseInt(tokenId);
            token["sort"] = r[6];
            this.tokens.push(token)
          })
        } catch (err) {
          console.log(err.message);


        }
      },
      async quitSoldToken(tokenId) {
        try {
          if (web3.currentProvider.publicConfigStore._state.networkVersion !== '3') {
            this.ropsten = true
            return
          } 
          this.loading = true;
          await this.instance.quitSoldToken(tokenId, false, { from: this.account, gas:3000000, gasPrice: this.gasPrice}).then(async (r) => {
            
            this.loading = false;
            const rawTxUrl = "https://ropsten.etherscan.io/tx/" + r.tx
            this.txUrl = "success! check it: <a href=" + rawTxUrl + " target='_blank'}>" + rawTxUrl + "</a>"

            this.txSuccess = true
            console.log(r)
            await this.updatetokens();
          })
        } catch (err) {
          this.loading = false;
          console.log(err.message);
          alert(err.message + " or Use ropsten net( You can't use this function), check it https://qiita.com/tmikada/items/cdc5a3871f655cb7b67d  ")

        }
      },
      async buyToken(tokenId, tokenPrice) {
        try {
          if (web3.currentProvider.publicConfigStore._state.networkVersion !== '3') {
            this.ropsten = true
            return
          } 
          this.loading = true;
          await this.instance.purchase(tokenId, { from: this.account, value: web3.toWei(tokenPrice, "wei"), gas:3000000, gasPrice: this.gasPrice}).then(async (r) => {
            this.loading = false;
            const rawTxUrl = "https://ropsten.etherscan.io/tx/" + r.tx
            this.txUrl = "success! check it: <a href=" + rawTxUrl + " target='_blank'}>" + rawTxUrl + "</a>"
            this.txSuccess = true
            console.log(r)
            await this.updatetokens();
          })
        } catch (err) {
          this.loading = false;
          console.log(err.message);
          alert(err.message + " or Use ropsten net( You can't use this function), check it https://qiita.com/tmikada/items/cdc5a3871f655cb7b67d  ")

        }
      },  

      async getGasPrice() {
        await web3.eth.getGasPrice((err, result) => {
          if (err) {
            console.log(err.message);
            alert(err.message)
          } else {        
            this.gasPrice = result.toString(10);  
                // this.gasPriceInGwei = result.toString(10);
              // this.gasPriceInGwei = web3.fromWei(result.toString(10), 'gwei');                                  
              // return gasPriceInGwei
          }
        })
      }
    }
	}

</script>


<style lang="scss" scoped>
  .md-card {
    width: 350px;
    margin: 4px;
    display: inline-block;
    vertical-align: top;
  }
  .md-card-example {
    .md-subhead {
      .md-icon {
        $size: 16px;
        width: $size;
        min-width: $size;
        height: $size;
        font-size: $size !important;
      }
      span {
        vertical-align: middle;
      }
    }
    .card-reservation {
      margin-top: 8px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      .md-icon {
        margin: 8px;
      }
    }
    .md-button-group {
      display: flex;
      .md-button {
        min-width: 60px;
        border-radius: 2px;
      }
    }
  }
  img {
   width: 200px;
   max-height: 200px;
  }
  .image-estate {
    width: 282px;
    max-height: 282px;
  }
  
</style>
