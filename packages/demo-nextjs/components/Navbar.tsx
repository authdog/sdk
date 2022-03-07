/* eslint-disable @next/next/no-img-element */
import { Grid, GridItem, Button, Divider } from '@chakra-ui/react';

import {
  Menu,
  MenuButton,
  MenuList,
  MenuItem,
} from '@chakra-ui/react'

// import {ChevronDownIcon} from '@chakra-ui/icons'

import { Avatar, Wrap, WrapItem } from '@chakra-ui/react'


const LOGO_AUTHDOG =
  'https://res.cloudinary.com/authdog/image/upload/v1632157556/Web/images/corporate/Authdog_Full-Colour_lf2qex.svg';

// @ts-ignore
import {logout} from '@authdog/web-sdk'

interface INavbar {
  user?: any;
  onLogout?: () => void;
  signinUri: string;
}

export const Navbar = ({
  user,
  signinUri
}: INavbar) => {

  const signin = (signinUri: string) => {
    window.location.href = signinUri;
  };

  const picture = user?.photos?.length > 0 ? user.photos[0]["value"]: null;

  return (
    <div style={{ padding: '2em' }}>
      <Grid templateColumns="repeat(2, 1fr)" gap={6}>
        <GridItem w="100%" h="10" style={{ cursor: 'pointer' }} onClick={() => {
          window.location.href = 'https://www.authdog.com'
        }}>
          <img src={LOGO_AUTHDOG} alt="Authdog" width={190} height="100%" />
        </GridItem>
        <GridItem
          w="100%"
          h="10"
          style={{ textAlign: 'right' }}
        >
          {user ? (
           <Menu>
            <MenuButton as={Button} 
            //rightIcon={<ChevronDownIcon />}
            >
              <Wrap style={{ display: "flex" }}>
                <WrapItem style={{ marginTop: '11px' }}>
                  Hello {user.displayName} &nbsp; 

                </WrapItem>
                <WrapItem>
                  
                  <Avatar size='sm' name={user?.displayName} src={picture} />
                </WrapItem>
              </Wrap>

            </MenuButton>
            <MenuList>
              <MenuItem onClick={() => {
                logout({
                  tenantUri: '',
                  applicationUuid: ''
                })
              }}>Logout</MenuItem>
            </MenuList>
          </Menu>
          )
          : (
            <Button colorScheme="blue" size="lg" onClick={() => signin(signinUri)}>
            Sign In
          </Button>
          )
          }
        </GridItem>
      </Grid>
      <br />
      <br />
      <Divider />
    </div>
  );
};
