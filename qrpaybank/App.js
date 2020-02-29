import React from 'react';
import { StyleSheet, Text, View, Dimensions, TouchableOpacity } from 'react-native';
import { Container, Header, Content, Input, Item, Body, Left, Button, Right, Title } from 'native-base';

import QRCode from 'react-native-webview-qrcode';

import RequestJson from './requestData.json';
import company from './company.json';


export default class App extends React.Component {
  constructor() {
    super();
    this.state = {
      price: '',
      companyName: '',
      companyIBAN: '',
      jsonStringified: 'wroıoıong',
      showQR: false
    }
  }

  componentDidMount() {
    this.setState({
      companyName: company.name,
      companyIBAN: company.iban
      });
  }

  render() {
    return (
      <Container>
        <Header>
          <Left/>
            <Body>
              <Title>QR Pay</Title>
            </Body>
          <Right/>
        </Header>

        <Content style={styles.content}>
          <Text style={styles.greeting}>{this.state.companyName}</Text>

          <View style={styles.priceFieldContainer}>
            <Item regular style={styles.priceBox}>
              <Input placeholder='Price' onChangeText={text => this.onChangeText(text)}/>
            </Item>
          </View>
        
          <View style={styles.buttonContainer}>
            <Button primary style={styles.buttonStyle} onPress={() => {
              this.updateJsonFile();
              this.setState({showQR: true});
            }
              }>
              <Text style={styles.buttonText}>QR Oluştur</Text>
            </Button>
          </View>
        
          <View style={styles.qrContainer}>
            { this.displayQR() }
          </View>
          
          
        </Content>
      </Container>
    )
  }

  onChangeText = (text) => {
    if (this.state.price !== 0) {
      this.setState({
        price: text,
        showQR: false
      });
    }
  }

  updateJsonFile = () => {
    RequestJson.data.Message.TransferAmount.Value = this.state.price;
    RequestJson.data.Message.SourceAccount.IBAN = this.state.companyIBAN;

    console.log()
  }

  displayQR = () => {
    if (this.state.showQR) {      
      return   <QRCode
      value={this.state.price}
      size={250}
      bgColor="#000"
      fgColor="#fff"
      />
    }
    return null
  }

}

const styles = StyleSheet.create({
  container: {
    marginTop: Dimensions.get('window').height * 15 / 100,
    alignItems: 'center',
    justifyContent: 'center'
  },

  greeting: {
    marginTop: Dimensions.get('window').height * 5 / 100,
    marginBottom: Dimensions.get('window').height * 5 / 100,
    fontSize: 21,
    paddingLeft: 20
  },

  buttonText: {
    textAlign: 'center',
    alignContent: 'center',
    fontSize: 15,
    paddingLeft: 10,
    fontWeight: 'bold',
    color: 'white'
  },

  buttonStyle: {
    flex: 1, 
    marginTop: 10,
    flexDirection: 'row',
    width: 100
  },

  buttonContainer: {
    flex:1,
    alignItems:'center'
  },

  content: {
    marginLeft: Dimensions.get('window').width * 5 / 100,
    marginRight: Dimensions.get('window').width * 5 / 100
  },

  priceFieldContainer: {
    flex:1,
    alignItems:'center'
  },
  
  price: {
    fontSize: 20,
    marginLeft: 5,
    marginBottom: 3
  },

  priceBox: {
    width: Dimensions.get('window').width * 80 / 100
  },

  qrContainer: {
    paddingTop: Dimensions.get('window').height * 7.5 / 100,
    flex:1,
    alignItems:'center'
  }
});
