#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

#include "dc_client.h"

#include "tc.h"


int cyc= 1;
int sub= 0;
int ckp= 0;
int msg= 0;

static void
send_subresult(int c)
{
  char l[100];
  char p[100];
  char s[100];

  printf("cyc=%d Sending subresult...\n", c);
  sprintf(l, "l_%d", c);
  sprintf(p, "p_%d", c);
  sprintf(s, "subresult %d", c);
  create_file(p, s);
  DC_sendResult(l, p, DC_FILE_REGULAR);
}

static void
mk_checkpoint(int c)
{
  printf("cyc=%d Making checkpoint...\n", c);
}

static void
send_message(int c)
{
  char s[100];

  printf("cyc=%d Sending message...\n", c);
  sprintf(s, "Message=%d, cyc=%d", msg, c);
  DC_sendMessage(s);
}

int
main(int argc, char *argv[])
{
  DC_initClient();
  int i;

  if (argc > 1)
    {
      cyc= strtol(argv[1], 0, 0);
      printf("cyc defined= %d\n", cyc);
    }
  if (argc > 2)
    {
      sub= strtol(argv[2], 0, 0);
      printf("sub defined= %d\n", sub);
    }
  if (argc > 3)
    {
      ckp= strtol(argv[3], 0, 0);
      printf("ckp defined= %d\n", ckp);
    }
  if (argc > 4)
    {
      msg= strtol(argv[4], 0, 0);
      printf("msg defined= %d\n", msg);
    }

  i= 0;
  while (cyc)
    {
      cyc--;
      i++;
      printf("\nCycle %d. starting...\n", i);
      sleep(1);
      if (sub &&
	  i%sub == 0)
	send_subresult(i);
      if (ckp &&
	  i%ckp == 0)
	mk_checkpoint(i);
      if (msg)
	{
	  send_message(i);
	  msg--;
	}
      printf("Done, remaining cycles: %d\n", cyc);
    }

  DC_finishClient(0);
}
