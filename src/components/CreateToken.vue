<template>
  <div style="margin: 20px 20px 50px 20px;" v-loading="loading">
    
    <el-row :gutter="20">
    <el-col :span="12" :offset="6">
    <el-form :label-position="labelPosition" label-width="100px" :model="formLabelAlign">
      <el-form-item label="Token Name" >
        <el-input v-model="formLabelAlign.name" placeholder="enter token name"></el-input>
      </el-form-item>
      <el-form-item label="Token Details">
        <el-input type="textarea" v-model="formLabelAlign.details" placeholder="enter token details"></el-input>
      </el-form-item>
      <el-form-item label="Price(eth)">
        <el-input v-model="formLabelAlign.price" placeholder="enter price like 1.26"></el-input>
      </el-form-item>
      <el-form-item label="Sell in Market">
        <el-switch v-model="formLabelAlign.sold"></el-switch>
      </el-form-item>
      <el-form-item label="Select Image">
        <md-radio v-model="formLabelAlign.sort" :value="0" class="md-primary">Anything (default)</md-radio>
        <md-radio v-model="formLabelAlign.sort" value="1" class="md-primary">Estate</md-radio>
        <md-radio v-model="formLabelAlign.sort" value="2" class="md-primary">Ticket</md-radio>
        <md-radio v-model="formLabelAlign.sort" value="3" class="md-primary">Copyright</md-radio>
        <md-radio v-model="formLabelAlign.sort" disabled class="md-primary">Rental</md-radio>
        <md-radio v-model="formLabelAlign.sort" disabled class="md-primary">Auction</md-radio>
        
      </el-form-item>
      
      <el-button type="primary" @click="createToken(formLabelAlign)">Create</el-button>
    </el-form>
    </el-col>
  </el-row>
  
    <md-dialog-alert
            :md-active.sync="formLabelAlign.ropsten"
            md-content="Alert: Use ropsten net( You can't use this function), check it https://qiita.com/tmikada/items/cdc5a3871f655cb7b67d"
            md-confirm-text="Cancel" />
    <md-dialog-alert
            :md-active.sync="formLabelAlign.txSuccess"
            :md-content="formLabelAlign.txUrl"
            md-confirm-text="Cancel" />
          
  
  </div>
</template>


<script>
  import Web3 from 'web3'
  import contract from 'truffle-contract'
  import artifacts from '../../build/contracts/createToken.json'
  const CreateToken = contract(artifacts)
  export default {
    name: 'CreateToken',
    data() {
      return {
        labelPosition: 'right',
        gasPrice: 2,
        formLabelAlign: {
          name: 'token name hoge',
          details: 'token details hoge',
          price: '0.1',
          sold: true,
          ropsten: false,
          txSuccess: false,
          txUrl: "",
          sort: 0,
        },
      loading: false,
      };
    },
    async created () {

      try {
        web3 = await new Web3(web3.currentProvider)

        CreateToken.setProvider(web3.currentProvider)
        await web3.eth.getAccounts(async (err, accs) => {
          if (web3.currentProvider.publicConfigStore._state.networkVersion !== '3') {
            this.formLabelAlign.ropsten = true
            return
          } 
          this.account = accs[0];
          console.log(this.account)
          this.instance = await CreateToken.deployed()
          await this.getGasPrice()

        })
      } catch (err) {
        console.log(err.message)
        this.formLabelAlign.ropsten = true

      }
    
      //  this.instance = await CreateToken.at(constact_address)
      // this.instance = await web3.eth.contract(artifacts.abi);
      // this.instance ＝await this.instance.at("0x9219a7ae0edc285c97604c34358132e180bff2f30");
    },
    methods: {
      async createToken(item) {
        try {
          if (web3.currentProvider.publicConfigStore._state.networkVersion !== '3') {
            this.formLabelAlign.ropsten = true
            return
          } 
        
        // dealing with decimal point, and double-byte
          item.price = await this.toHalfWidth(item.price)
          
          this.loading = true;
          return await this.instance.mint(item.name, item.details, web3.toWei(parseFloat(item.price), "ether"), item.sold, item.sort, { from: this.account, gasPrice: this.gasPrice}).then((r) => {
            console.log(r)
            console.log("success")
            this.loading = false;
            const rawTxUrl = "https://ropsten.etherscan.io/tx/" + r.tx
            this.formLabelAlign.txUrl = "success! check it: <a href=" + rawTxUrl + " target='_blank'}>" + rawTxUrl + "</a>"

            this.formLabelAlign.txSuccess = true
            // this.txUrl = 'https://ropsten.etherscan.io/tx/' + r.tx
            // alert("success! check it: " + this.formLabelAlign.txUrl)
            
          })
        } catch (err) {
          this.loading = false;
          console.log(err.message);
          // alert("Error: " + err.message)       
          // Temporary comment 
          // this.formLabelAlign.ropsten = true
          alert(err.message + " or Use ropsten net( You can't use this function), check it https://qiita.com/tmikada/items/cdc5a3871f655cb7b67d  ")
          return
        }
      },
      
      toHalfWidth(value) {
        return value.replace(/[！-～]/g, (s) => {
          return String.fromCharCode(s.charCodeAt(0) - 0xFEE0);
        });
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

<style scoped>
  .el-form {
    width: 550px;
  
  }
  .el-switch {
    margin-right: 320px;
  }
  .el-button {
    margin-left: 90px;
  }
</style>
