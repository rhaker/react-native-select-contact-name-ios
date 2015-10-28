/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 */
'use strict';

var React = require('react-native');
var { NativeModules } = React;
var { RNSelectContactName } = NativeModules;

var {
  AppRegistry,
  StyleSheet,
  Text,
  View,
} = React;

var testComp = React.createClass({
  componentDidMount() {
    this._selectName();
  },
  async _selectName() {
    console.log('in select name');
    try {
      let value = await RNSelectContactName.selectName(true);
      console.log('Name: ' + value.firstName,value.middleName,value.lastName);
    } catch (error) {
      console.log('Error: ' + error.message);
    }
  },
  render: function() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>
          Select Name - View Xcode Log
        </Text>
        <Text style={styles.instructions}>
          Press Cmd+R to reload,{'\n'}
          Cmd+D or shake for dev menu
        </Text>
      </View>
    );
  }
});

var styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});

AppRegistry.registerComponent('testComp', () => testComp);
