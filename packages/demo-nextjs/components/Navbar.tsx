import { Grid, GridItem, Button, Divider } from '@chakra-ui/react';

import { default as Image } from 'next/image';

const LOGO_AUTHDOG =
  'https://res.cloudinary.com/authdog/image/upload/v1632157556/Web/images/corporate/Authdog_Full-Colour_lf2qex.svg';

export const Navbar = () => {
  return (
    <div style={{ padding: '2em' }}>
      <Grid templateColumns="repeat(2, 1fr)" gap={6}>
        <GridItem w="100%" h="10">
          <Image src={LOGO_AUTHDOG} alt="Authdog" width={190} height="100%" />
        </GridItem>
        <GridItem
          w="100%"
          h="10"
          style={{ textAlign: 'right', padding: '1.5em' }}
        >
          <Button colorScheme="blue" size="lg">
            Sign In
          </Button>
        </GridItem>
      </Grid>
      <br />
      <br />
      <Divider />
    </div>
  );
};
