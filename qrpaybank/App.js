import React from 'react';
import { StyleSheet, Text, View, Dimensions, TouchableOpacity } from 'react-native';
import { Container, Header, Content, Input, Item, Body, Left, Button, Right, Title, Icon } from 'native-base';
import {KeyboardAvoidingView} from 'react-native'


import QRCode from 'react-native-webview-qrcode';

export default class App extends React.Component {
  constructor() {
    super()
    this.state = {
      price: '',
      showQR: false
    }
  }

  render() {
    return (
      <KeyboardAvoidingView  keyboardVerticalOffset = {Header.HEIGHT + 20}
      style = {{flex: 1}}
      behavior = "padding">
        <Container>
          <Header>
            <Left/>
              <Body>
                <Title>QR Pay</Title>
              </Body>
            <Right/>
          </Header>

          <Content style={styles.content}>
            <Text style={styles.greeting}>QR-Odeme - Happy Moons Fenerbahce</Text>

            <Text style={styles.price}>Price</Text>
            <Item regular style={styles.priceBox}>
              <Input placeholder='Price' onChangeText={text => this.onChangeText(text)}/>
            </Item>

            <Button primary style={styles.buttonStyle} onPress={() =>  {this.setState({showQR: true})}}>
              <Text style={styles.buttonText}>QR Oluştur</Text>
            </Button>

            {this.state.showQR && (
                  <QRCode
                    value={this.state.price}
                    style={{position: 'absolute', bottom: 0, marginTop: 100, marginLeft: 50}}
                    //Setting the value of QRCode
                    size={250}
                    //Size of QRCode
                    bgColor="#000"
                    //Backgroun Color of QRCode
                    fgColor="#fff"
                    //Front Color of QRCode
              />
              ) 
              }
          </Content>
        </Container>
      </KeyboardAvoidingView>

  )
  }

  onChangeText = (text) => {
    if (!this.state.showQR) {
      this.setState({
        price: text
      });
    }
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
    fontSize: 21
  },

  buttonText: {
    textAlign: 'center',
    alignContent: 'center',
    fontSize: 15,
    fontWeight: 'bold',
    color: 'white'
  },

  buttonStyle: {
    flex: 1, 
    marginTop: 10,
    flexDirection: 'row',
    justifyContent: 'center', 
    width: 100,
    marginLeft: Dimensions.get('window').width * 56 / 100
  },

  content: {
    marginLeft: Dimensions.get('window').width * 5 / 100,
    marginRight: Dimensions.get('window').width * 5 / 100
  },
  
  price: {
    fontSize: 20,
    marginLeft: 5,
    marginBottom: 3
  },

  priceBox: {
    width: Dimensions.get('window').width * 80 / 100
  }
});
